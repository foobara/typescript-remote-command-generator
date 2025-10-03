require_relative "generate_typescript"

module Foobara
  module RemoteGenerator
    class WriteTypescriptToDisk < Generators::WriteGeneratedFilesToDisk
      class << self
        def generator_key
          "typescript-remote-commands"
        end
      end

      # TODO: shouldn't have to qualify DataError like this
      class MissingManifestError < Value::DataError
        class << self
          def context_type_declaration
            {}
          end
        end
      end

      possible_error MissingManifestError

      inputs do
        raw_manifest :associative_array, :allow_nil
        manifest_url :string, :allow_nil
        # TODO: should be able to delete this and inherit it
        output_directory :string, default: "src/domains"
      end

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
        if raw_manifest.nil? && manifest_url.nil?
          add_input_error(
            MissingManifestError.new(
              message: "Must provide either raw_manifest or manifest_url",
              context: {}
            )
          )
        end
      end

      def generate_typescript
        # TODO: we need a way to allow values to be nil in type declarations
        inputs = raw_manifest ? { raw_manifest: } : { manifest_url: }

        self.paths_to_source_code = run_subcommand!(GenerateTypescript, inputs)
      end

      def run_post_generation_tasks
        eslint_fix
        warn_about_adding_setup_to_index
      end

      def eslint_fix
        cmd = "npx eslint 'src/**/*.{js,jsx,ts,tsx}' --fix"

        Open3.popen3(cmd) do |_stdin, _stdout, stderr, wait_thr|
          exit_status = wait_thr.value
          unless exit_status.success?
            # :nocov:
            warn "WARNING: could not #{cmd}\n#{stderr.read}"
            # :nocov:
          end
        end
      end

      def warn_about_adding_setup_to_index
        if paths_to_source_code.key?("setup.ts")
          index_tsx_path = "#{output_directory}/index.tsx"

          if File.exist?(index_tsx_path)
            unless File.read(index_tsx_path) =~ /import.*domains\/setup/
              warn "WARNING: you should add the following to src/index.tsx:\n\n" \
                   "import './domains/setup'"
            end
          else
            # :nocov:
            warn "WARNING: Make sure you add the following somewhere:\n\n" \
                 "import './domains/setup'"
            # :nocov:
          end
        end
      end
    end
  end
end
