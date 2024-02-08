module Foobara
  module RemoteGenerator
    class Services
      class EntityManifestGenerator < ManifestGenerator
        def target_path
          [*domain_path, "entities", entity_name, "manifest.json"]
        end
      end
    end
  end
end
