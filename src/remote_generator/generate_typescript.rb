module Foobara
  module RemoteGenerator
    class GenerateTypescript < Foobara::Command
      # TODO: give better sugar for specifying required inputs
      inputs raw_manifest: { type: :associative_array, required: true }

      # TODO: specify a better type?
      result :associative_array

      def execute
        generate_base_files

        add_all_commands_to_set_of_elements_to_generate

        each_element_to_generate do
          generate_element
        end

        generate_generated_files_json

        paths_to_source_code
      end

      attr_accessor :command_manifest, :element_to_generate, :generator

      def elements_to_generate
        @elements_to_generate ||= Set.new
      end

      def generated
        @generated ||= Set.new
      end

      def each_element_to_generate
        until elements_to_generate.empty?
          self.element_to_generate = elements_to_generate.first
          elements_to_generate.delete(element_to_generate)

          unless generated.include?(element_to_generate)
            yield
            generated << element_to_generate
          end
        end
      end

      def add_all_commands_to_set_of_elements_to_generate
        manifest.commands.each do |command|
          elements_to_generate << command
        end
      end

      def generate_element
        each_generator do
          run_generator
        end
      end

      def run_generator
        paths_to_source_code[generator.target_path.join("/")] = generator.generate
      end

      def each_generator
        RemoteGenerator.generators_for(element_to_generate, elements_to_generate).each do |generator|
          self.generator = generator
          yield
        end
      end

      def manifest
        @manifest ||= Manifest::RootManifest.new(raw_manifest)
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
        "#{__dir__}/templates"
      end

      def generate_generated_files_json
        paths_to_source_code["foobara-generated.json"] = "[\n#{
          paths_to_source_code.keys.map { |k| "  \"#{k}\"" }.join(",\n")
        }\n]\n"
      end
    end
  end
end
