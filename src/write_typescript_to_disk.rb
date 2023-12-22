module Foobara
  module RemoteGenerator
    class WriteTypescriptToDisk < Foobara::Command
      class MissingManifestError < RuntimeError; end

      possible_error MissingManifestError

      # TODO: give better sugar for specifying required inputs
      inputs raw_manifest: { type: :associative_array },
             manifest_url: { type: :string },
             output_directory: { type: :string, required: true }

      depends_on GenerateTypescript

      def execute
        generate_typescript

        write_to_disk
      end

      def write_all_to_tmp(result)
        file_list_file = "#{output_directory}/foobara-generated.json"

        if File.exist?(file_list_file)
          file_list = JSON.parse(File.read(file_list_file))

          file_list = file_list.map { |file| file.split("/").first }

          file_list.uniq.each do |file|
            FileUtils.rm_rf("#{out_dir}/#{file}")
          end

          FileUtils.rm_rf(file_list_file)
        end

        write_to_tmp("foobara-generated.json", result["foobara-generated.json"])

        result.map do |path, contents|
          Thread.new { write_to_tmp(path, contents) unless path == "foobara-generated.json" }
        end.each(&:join)
      end

      def write_to_tmp(path, contents)
        path = "#{out_dir}/#{path}"
        FileUtils.mkdir_p(File.dirname(path))
        File.write(path, contents)
      end
    end
  end
end
