module Foobara
  module RemoteGenerator
    class Services
      class ModelManifestGenerator < ManifestGenerator
        def target_path
          [*domain_path, "types", model_name, "manifest.json"]
        end
      end
    end
  end
end
