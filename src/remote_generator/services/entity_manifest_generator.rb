require_relative "base_generator"

module Foobara
  module RemoteGenerator
    class Services
      class EntityManifestGenerator < BaseGenerator
        alias entity_manifest relevant_manifest

        def target_path
          [*domain_path, "entities", entity_name, "manifest.json"]
        end

        def generate
          JSON.pretty_generate(entity_manifest.relevant_manifest)
        end
      end
    end
  end
end
