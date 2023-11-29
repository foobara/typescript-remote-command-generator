require_relative "base_generator"

module Foobara
  module RemoteGenerator
    class TypeScriptGenerator
      class OrganizationGenerator < BaseGenerator
        alias organization_manifest relevant_manifest

        def target_path
          [organization_name, "index.ts"]
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
