require "net/http"
require "uri"

module Foobara
  module RemoteGenerator
    class GenerateTypescript < Foobara::Generators::Generate
      class MissingManifestError < RuntimeError; end

      possible_error MissingManifestError

      inputs raw_manifest: :associative_array,
             manifest_url: :string

      def execute
        load_manifest_if_needed

        include_non_templated_files

        add_root_manifest_to_set_of_elements_to_generate
        add_all_commands_to_set_of_elements_to_generate

        each_element_to_generate do
          generate_element
        end

        paths_to_source_code
      end

      def validate
        if raw_manifest.nil? && manifest_url.nil?
          # :nocov:
          add_runtime_error(MissingManifestError.new(message: "Either raw_manifest or manifest_url must be given"))
          # :nocov:
        end
      end

      attr_accessor :command_manifest, :manifest_data

      def base_generator
        Services::TypescriptFromManifestBaseGenerator
      end

      def templates_dir
        "#{__dir__}/../../templates"
      end

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

      def manifest
        @manifest ||= Manifest::RootManifest.new(manifest_data)
      end
    end
  end
end
