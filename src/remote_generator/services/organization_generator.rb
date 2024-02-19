require_relative "typescript_from_manifest_base_generator"

module Foobara
  module RemoteGenerator
    class Services
      class OrganizationGenerator < TypescriptFromManifestBaseGenerator
        alias organization_manifest relevant_manifest

        def import_destructure
          "* as #{organization_name}"
        end

        def target_path
          if global?
            ["GlobalOrganization", "index.ts"]
          else
            [*scoped_full_path, "index.ts"]
          end
        end

        def template_path
          "Organization.ts.erb"
        end

        def domain_generators
          @domain_generators ||= organization_manifest.domains.map do |domain_manifest|
            DomainGenerator.new(domain_manifest, elements_to_generate)
          end
        end

        def dependencies
          domain_generators
        end

        def organization_name
          scoped_short_name || "GlobalOrganization"
        end
      end
    end
  end
end
