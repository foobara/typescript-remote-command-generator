require "pathname"
require_relative "generate_typescript"

module Foobara
  module RemoteGenerator
    class WriteTypescriptToDisk < Foobara::Generators::WriteGeneratedFilesToDisk
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
        auto_dirty_queries :boolean, default: false
        no_foobara_auth :boolean,
                        default: false,
                        description: "Never generate Foobara::Auth's RequiresAuthCommand, even if the " \
                                     "manifest contains that domain. For apps that import it from elsewhere."
        env_expression :env_expression, default: "import.meta.env"
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

        inputs[:auto_dirty_queries] = auto_dirty_queries
        inputs[:no_foobara_auth] = no_foobara_auth
        inputs[:env_expression] = env_expression

        self.paths_to_source_code = run_subcommand!(GenerateTypescript, inputs)
      end

      def run_post_generation_tasks
        Dir.chdir(project_directory || output_directory) do
          eslint_fix if eslint_config_present?
          oxlint_fix if oxlint_config_present?
          prettier_write if prettier_config_present?
        end
      end

      def output_directory_relative_to_project
        return @output_directory_relative_to_project if defined?(@output_directory_relative_to_project)

        project_path = Pathname.new(File.expand_path(project_directory || output_directory))
        pathname = Pathname.new(File.expand_path(output_directory))

        @output_directory_relative_to_project = pathname.relative_path_from(project_path).to_s
      end

      def eslint_config_present? = any_files_present?("eslint.config.*", ".eslintrc", ".eslintrc.*")
      def oxlint_config_present? = any_files_present?(".oxlintrc.json", "oxlint.config.*")
      def prettier_config_present? = any_files_present?("prettier.config.*", ".prettierrc", ".prettierrc.*")
      def any_files_present?(*globs) = !Dir.glob(globs).empty?

      def eslint_fix
        run_lint_cmd("npx eslint '#{output_directory_relative_to_project}/**/*.{js,jsx,ts,tsx}' --fix")
      end

      def oxlint_fix
        run_lint_cmd("npx oxlint --fix '#{output_directory_relative_to_project}'")
      end

      def prettier_write
        run_lint_cmd("npx prettier --write '#{output_directory_relative_to_project}/**/*.{js,jsx,ts,tsx}'")
      end

      def run_lint_cmd(cmd)
        out, err, exit_status = Open3.capture3(cmd)

        unless exit_status.success?
          # simplecov:disable
          if fail_if_does_not_pass_linter?
            add_runtime_error :failed_to_lint, stdout: out, stderr: err
          else
            warn "WARNING: could not #{cmd}\n#{out}\n#{err}"
          end
          # simplecov:enable
        end
      end

      def fail_if_does_not_pass_linter? = fail_if_does_not_pass_linter
    end
  end
end
