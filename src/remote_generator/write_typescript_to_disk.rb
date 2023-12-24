require_relative "generate_typescript"

module Foobara
  module RemoteGenerator
    class WriteTypescriptToDisk < Foobara::Command
      class MissingManifestError < RuntimeError; end

      possible_error MissingManifestError

      # TODO: give better sugar for specifying required inputs
      inputs raw_manifest: { type: :associative_array },
             manifest_url: { type: :string },
             output_directory: { type: :string, required: true }
      result :associative_array

      depends_on GenerateTypescript

      def execute
        generate_typescript
        delete_old_files_if_needed
        write_all_files_to_disk

        paths_to_source_code
      end

      attr_accessor :paths_to_source_code

      def generate_typescript
        # TODO: we need a way to allow values to be nil in type declarations
        inputs = raw_manifest ? { raw_manifest: } : { manifest_url: }

        self.paths_to_source_code = run_subcommand!(GenerateTypescript, inputs)
      end

      def delete_old_files_if_needed
        file_list_file = "#{output_directory}/foobara-generated.json"

        if File.exist?(file_list_file)
          file_list = JSON.parse(File.read(file_list_file))

          file_list.map do |file|
            Thread.new { FileUtils.rm("#{output_directory}/#{file}") }
          end.each(&:join)
        end
      end

      def write_all_files_to_disk
        write_file_to_disk("foobara-generated.json", paths_to_source_code["foobara-generated.json"])

        paths_to_source_code.map do |path, contents|
          Thread.new { write_file_to_disk(path, contents) unless path == "foobara-generated.json" }
        end.each(&:join)
      end

      def write_file_to_disk(path, contents)
        path = "#{output_directory}/#{path}"
        FileUtils.mkdir_p(File.dirname(path))
        File.write(path, contents)
      end
    end
  end
end
