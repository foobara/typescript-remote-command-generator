require_relative "generate_typescript"
require_relative "../write_generated_files_to_disk"

module Foobara
  module RemoteGenerator
    class WriteTypescriptToDisk < Foobara::Generators::WriteGeneratedFilesToDisk
      class MissingManifestError < RuntimeError; end

      possible_error MissingManifestError

      inputs do
        raw_manifest :associative_array
        manifest_url :string
        # TODO: should be able to delete this and inherit it
        output_directory :string, :required
      end

      depends_on GenerateTypescript

      def execute
        generate_typescript
        delete_old_files_if_needed
        write_all_files_to_disk

        paths_to_source_code
      end

      def generate_typescript
        # TODO: we need a way to allow values to be nil in type declarations
        inputs = raw_manifest ? { raw_manifest: } : { manifest_url: }

        self.paths_to_source_code = run_subcommand!(GenerateTypescript, inputs)
      end
    end
  end
end
