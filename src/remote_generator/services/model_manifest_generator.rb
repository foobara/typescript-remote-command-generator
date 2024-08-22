module Foobara
  module RemoteGenerator
    class Services
      class ModelManifestGenerator < ManifestGenerator
        def target_path
          [*domain.scoped_full_path, "Types", *model_prefix, scoped_short_name, "manifest.json"]
        end

        # TODO: DRY this up
        def model_prefix
          path = scoped_prefix

          if path && !path.empty?
            if path.first == "Types"
              path[1..]
            else
              path
            end
          else
            []
          end
        end
      end
    end
  end
end
