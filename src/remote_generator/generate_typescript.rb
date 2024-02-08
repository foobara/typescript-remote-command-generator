require "net/http"
require "uri"

module Foobara
  module RemoteGenerator
    class GenerateTypescript < Foobara::Command
      class MissingManifestError < RuntimeError; end

      possible_error MissingManifestError

      # TODO: give better sugar for specifying required inputs
      inputs raw_manifest: { type: :associative_array },
             manifest_url: { type: :string }

      # TODO: specify a better type?
      result :associative_array

      def execute
        load_manifest_if_needed

        generate_base_files

        add_root_manifest_to_set_of_elements_to_generate
        add_all_commands_to_set_of_elements_to_generate

        each_element_to_generate do
          generate_element
        end

        generate_generated_files_json

        paths_to_source_code
      end

      def validate
        if raw_manifest.nil? && manifest_url.nil?
          # :nocov:
          add_runtime_error(MissingManifestError.new("Either raw_manifest or manifest_url must be given"))
          # :nocov:
        end
      end

      attr_accessor :command_manifest, :element_to_generate, :generator, :manifest_data

      def load_manifest_if_needed
        self.manifest_data = if raw_manifest
                               raw_manifest
                               # TODO: introduce VCR to test the following elsif block
                               # :nocov:
                             elsif manifest_url
                               url = URI.parse(manifest_url)
                               response = Net::HTTP.get_response(url)

                               manifest_json = if response.is_a?(Net::HTTPSuccess)
                                                 response.body
                                               else
                                                 raise "Could not get manifest from #{url}: " \
                                                       "#{response.code} #{response.message}"
                                               end

                               JSON.parse(manifest_json)
                               # :nocov:
                             end
      end

      def elements_to_generate
        @elements_to_generate ||= Set.new
      end

      def generated
        @generated ||= Set.new
      end

      def each_element_to_generate
        until elements_to_generate.empty?
          element_to_generate = elements_to_generate.first
          elements_to_generate.delete(element_to_generate)

          if element_to_generate.is_a?(Services::BaseGenerator)
            elements_to_generate << element_to_generate.relevant_manifest
            next
          end

          unless generated.include?(element_to_generate)
            self.element_to_generate = element_to_generate
            yield
            generated << element_to_generate
          end
        end
      end

      def add_all_commands_to_set_of_elements_to_generate
        manifest.commands.each do |command|
          elements_to_generate << command
          elements_to_generate << command.domain
          elements_to_generate << command.organization
        end
      end

      def add_root_manifest_to_set_of_elements_to_generate
        elements_to_generate << manifest
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
          next unless generator.applicable?

          self.generator = generator
          yield
        end
      end

      def manifest
        @manifest ||= Manifest::RootManifest.new(manifest_data)
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
          paths_to_source_code.keys.sort.map { |k| "  \"#{k}\"" }.join(",\n")
        }\n]\n"
      end
    end
  end
end
