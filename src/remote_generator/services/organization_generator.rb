require_relative "base_generator"

module Foobara
  module RemoteGenerator
    class Services
      class OrganizationGenerator < BaseGenerator
        alias organization_manifest relevant_manifest

        def target_path
          if global?
            ["GlobalOrganization.ts"]
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
          s = super

          if s == "global_organization"
            s = "GlobalOrganization"
          end

          s
        end
      end
    end
  end
end
