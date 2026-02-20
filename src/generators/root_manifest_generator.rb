require_relative "manifest_generator"

module Foobara
  module RemoteGenerator
    module Generators
      class RootManifestGenerator < ManifestGenerator
        def target_path
          ["manifest.json"]
        end
      end
    end
  end
end
