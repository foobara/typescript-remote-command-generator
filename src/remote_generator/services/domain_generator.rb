require_relative "base_generator"

module Foobara
  module RemoteGenerator
    class Services
      class DomainGenerator < TypeScriptFromManifestBaseGenerator
        alias domain_manifest relevant_manifest

        def import_destructure
          "* as #{domain_name}"
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

        def model_generators
          @model_generators ||= begin
            only_models = domain_manifest.models.reject(&:entity?)

            only_models.map do |model_manifest|
              ModelGenerator.new(model_manifest, elements_to_generate)
            end
          end
        end

        def dependencies
          [*command_generators, *model_generators, *entity_generators, *organization]
        end

        def domain_name
          scoped_short_name || "GlobalDomain"
        end

        def organization_generator
          @organization_generator ||= OrganizationGenerator.new(domain_manifest.organization, elements_to_generate)
        end

        foobara_delegate :organization_name, to: :organization_generator
      end
    end
  end
end
