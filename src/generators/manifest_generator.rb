require_relative "typescript_from_manifest_base_generator"

module Foobara
  module RemoteGenerator
    class Services
      class ManifestGenerator < TypescriptFromManifestBaseGenerator
        def generate(_elements_to_generate)
          JSON.pretty_generate(relevant_manifest.relevant_manifest)
        end
      end
    end
  end
end
