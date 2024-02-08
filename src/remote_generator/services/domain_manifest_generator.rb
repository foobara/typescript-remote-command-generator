require_relative "manifest_generator"

module Foobara
  module RemoteGenerator
    class Services
      class DomainManifestGenerator < ManifestGenerator
        def target_path
          if global?
            ["GlobalDomain", "manifest.json"]
          else
            [*scoped_full_path, "manifest.json"]
          end
        end
      end
    end
  end
end
