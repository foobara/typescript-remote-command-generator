require_relative "base_generator"

module Foobara
  module RemoteGenerator
    class Services
      class OrganizationGenerator < BaseGenerator
        alias organization_manifest relevant_manifest

        def target_path
          [*scoped_full_path, "index.ts"]
        end

        def template_path
          "Organization.ts.erb"
        end

        def domain_generators
          @domain_generators ||= organization_manifest.domains.map do |domain_manifest|
            DomainGenerator.new(domain_manifest)
          end
        end
      end
    end
  end
end
