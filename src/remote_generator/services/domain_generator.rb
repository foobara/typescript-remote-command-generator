require_relative "typescript_from_manifest_base_generator"

module Foobara
  module RemoteGenerator
    class Services
      class DomainGenerator < TypescriptFromManifestBaseGenerator
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
            generator_for(command_manifest)
          end
        end

        def entity_generators
          @entity_generators ||= domain_manifest.entities.map do |entity_manifest|
            EntityGenerator.new(entity_manifest)
          end
        end

        def type_generators
          @type_generators ||= begin
            # TODO: create a Manifest::Domain#custom_types
            only_custom_types = domain_manifest.types.reject(&:model?)
            only_custom_types.reject!(&:builtin?)

            only_custom_types.map do |type|
              TypeGenerator.new(type)
            end
          end
        end

        def model_generators
          # HERE!!!
          @model_generators ||= begin
            only_models = domain_manifest.models.reject(&:detached_entity?)

            only_models.map do |model_manifest|
              ModelGenerator.new(model_manifest)
            end
          end
        end

        def dependencies
          @dependencies ||= [*command_generators, *model_generators, *entity_generators, *type_generators,
                             *organization]
        end

        def domain_name
          scoped_name || "GlobalDomain"
        end

        def organization_generator
          @organization_generator ||= OrganizationGenerator.new(domain_manifest.organization)
        end

        def organization_name = organization_generator.organization_name
      end
    end
  end
end
