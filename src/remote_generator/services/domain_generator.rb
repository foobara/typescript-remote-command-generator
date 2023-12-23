require_relative "base_generator"

module Foobara
  module RemoteGenerator
    class Services
      class DomainGenerator < BaseGenerator
        alias domain_manifest relevant_manifest

        def target_path
          [*scoped_full_path, "index.ts"]
        end

        def template_path
          "Domain.ts.erb"
        end

        def command_generators
          @command_generators ||= domain_manifest.commands.map do |command_manifest|
            CommandGenerator.new(command_manifest, elements_to_generate)
          end
        end

        def entity_generators
          @entity_generators ||= domain_manifest.entities.map do |entity_manifest|
            EntityGenerator.new(entity_manifest, elements_to_generate)
          end
        end

        def dependencies
          [*command_generators, *entity_generators, *organization]
        end

        def domain_name
          s = super

          if s == "global_domain"
            s = "GlobalDomain"
          end

          s
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
