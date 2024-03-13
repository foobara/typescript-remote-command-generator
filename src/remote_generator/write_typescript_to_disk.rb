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
        output_directory :string, :required
      end

      depends_on GenerateTypescript

      def execute
        generate_typescript
        generate_generated_files_json
        delete_old_files_if_needed
        write_all_files_to_disk

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
    end
  end
end
