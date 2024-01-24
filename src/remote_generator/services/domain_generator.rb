require_relative "base_generator"

module Foobara
  module RemoteGenerator
    class Services
      class DomainGenerator < BaseGenerator
        alias domain_manifest relevant_manifest

        def import_destructure
          # "* as #{scoped_name}"
          super
        end

        def target_path
          if global?
            ["GlobalDomain", "index.ts"]
          else
            [*scoped_full_path, "index.ts"]
          end
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

        def organization_generator
          @organization_generator ||= OrganizationGenerator.new(domain_manifest.organization, elements_to_generate)
        end

        foobara_delegate :organization_name, to: :organization_generator
      end
    end
  end
end
