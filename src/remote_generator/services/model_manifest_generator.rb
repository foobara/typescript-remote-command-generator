module Foobara
  module RemoteGenerator
    class Services
      class ModelManifestGenerator < ManifestGenerator
        def target_path
          [*domain.scoped_full_path, "types", model_name, "manifest.json"]
        end
      end
    end
  end
end
