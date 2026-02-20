require_relative "generate_typescript"

module Foobara
  module RemoteGenerator
    class WriteTypescriptToDisk < Generators::WriteGeneratedFilesToDisk
      def self.generator_key = "typescript-remote-commands"

      inputs do
        raw_manifest :associative_array, :allow_nil
        manifest_url :string, :allow_nil
        # TODO: should be able to delete this and inherit it
        project_directory :string,
                          default: ".",
                          description: "This lets you specify a directory to run the linter or npm run build in"
        output_directory :string, default: "src/domains"
        fail_if_does_not_pass_linter :boolean, default: false
      end

      possible_error :missing_manifest
      possible_error :failed_to_lint, context: -> { stdout :string, :required; stderr :string, :required }

      depends_on GenerateTypescript

      def execute
        generate_typescript
        generate_generated_files_json
        delete_old_files_if_needed
        write_all_files_to_disk
        run_post_generation_tasks

        stats
      end

      def validate
        # TODO: kind of strange that we have to use a runtime error here. Maybe if input errors
        # supported the concept of multiple inputs this would be cleaner?
        if raw_manifest.nil? && manifest_url.nil?
          # TODO: we should support a sugar like:
          # add_runtime_error(
          #   :missing_manifest,
          #   "Must provide either raw_manifest or manifest_url",
          #   some_context_item: "blah"
          # )
          add_runtime_error(symbol: :missing_manifest, message: "Must provide either raw_manifest or manifest_url")
        end
      end

      def generate_typescript
        # TODO: we need a way to allow values to be nil in type declarations
        inputs = raw_manifest ? { raw_manifest: } : { manifest_url: }

        self.paths_to_source_code = run_subcommand!(GenerateTypescript, inputs)
      end

      def run_post_generation_tasks
        Dir.chdir(project_directory || output_directory) do
          eslint_fix
        end
      end

      def eslint_fix
        cmd = "npx eslint 'src/**/*.{js,jsx,ts,tsx}' --fix"

        Open3.popen3(cmd) do |_stdin, stdout, stderr, wait_thr|
          exit_status = wait_thr.value

          unless exit_status.success?
            # :nocov:
            out = stdout.read
            err = stderr.read

            if fail_if_does_not_pass_linter?
              add_runtime_error :failed_to_lint, stdout: out, stderr: err
            else
              warn "WARNING: could not #{cmd}\n#{out}\n#{err}"
            end
            # :nocov:
          end
        end
      end

      def fail_if_does_not_pass_linter? = fail_if_does_not_pass_linter
    end
  end
end
