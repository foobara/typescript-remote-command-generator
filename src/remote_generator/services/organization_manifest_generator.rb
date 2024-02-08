require_relative "manifest_generator"

module Foobara
  module RemoteGenerator
    class Services
      class OrganizationManifestGenerator < ManifestGenerator
        def target_path
          if global?
            ["GlobalOrganization", "manifest.json"]
          else
            [*scoped_full_path, "manifest.json"]
          end
        end
      end
    end
  end
end
