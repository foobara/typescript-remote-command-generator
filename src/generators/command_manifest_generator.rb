require_relative "manifest_generator"

module Foobara
  module RemoteGenerator
    class Services
      class CommandManifestGenerator < ManifestGenerator
        def target_path
          [*scoped_full_path, "manifest.json"]
        end
      end
    end
  end
end
