module Foobara
  module RemoteGenerator
    class GenerateTypescript < Foobara::Command
      # TODO: specify a better type?
      inputs manifest: :associative_array
      # TODO: specify a better type?
      result :associative_array

      def execute
        generate_base_files

        paths_to_source_code
      end

      def paths_to_source_code
        @paths_to_source_code ||= {}
      end

      def generate_base_files
        Dir["#{templates_dir}/base/**/*.ts"].each do |file_path|
          pathname = Pathname.new(file_path)

          key = pathname.relative_path_from(templates_dir)

          paths_to_source_code[key.to_s] = File.read(file_path)
        end
      end

      def templates_dir
        "#{__dir__}/../../templates"
      end
    end
  end
end
