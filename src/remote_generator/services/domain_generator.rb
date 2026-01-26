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

        def detached_entity_generators
          @detached_entity_generators ||= domain_manifest.detached_entities.flat_map do |entity_manifest|
            EntityVariantsGenerator.new(entity_manifest).dependencies.to_a
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
          @model_generators ||= begin
            only_models = domain_manifest.models.reject(&:detached_entity?)

            only_models.flat_map do |model_manifest|
              ModelVariantsGenerator.new(model_manifest).dependencies.to_a
            end
          end
        end

        def all_type_generators
          all_type_generators = []

          generators_allowed_for_inputs = [*type_generators, *model_generators]
          generators_allowed_for_errors_or_result = [*generators_allowed_for_inputs, *detached_entity_generators]

          Manifest::RootManifest.new(root_manifest).commands.each do |command_manifest|
            command_generator = CommandGenerator.new(command_manifest)

            command_generator.inputs_types_depended_on.each do |type_manifest|
              next unless type_manifest.domain == relevant_manifest

              generators_allowed_for_inputs.each do |generator|
                if generator.relevant_manifest == type_manifest
                  all_type_generators << generator
                end
              end
            end

            [
              *command_generator.result_type&.to_type,
              *command_generator.result_types_depended_on.each,
              *command_generator.errors_types_depended_on
            ].each do |type_manifest|
              next unless type_manifest.domain == relevant_manifest

              generators_allowed_for_errors_or_result.each do |generator|
                if generator.relevant_manifest == type_manifest
                  all_type_generators << generator
                end
              end
            end
          end

          all_type_generators.uniq!
          all_type_generators
        end

        def dependencies
          @dependencies ||= [*command_generators, *all_type_generators, organization]
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
