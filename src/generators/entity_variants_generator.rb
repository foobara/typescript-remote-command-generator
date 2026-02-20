require_relative "model_variants_generator"

module Foobara
  module RemoteGenerator
    class Services
      class EntityVariantsGenerator < EntityGenerator
        def target_path
          *prefix, _entity_name, _file = super

          [*prefix, "#{entity_short_name}.ts"]
        end

        def template_path
          "EntityVariants.ts.erb"
        end

        def entity_generator
          EntityGenerator.new(entity_manifest)
        end

        def unloaded_entity_generator
          UnloadedEntityGenerator.new(entity_manifest)
        end

        def loaded_entity_generator
          LoadedEntityGenerator.new(entity_manifest)
        end

        def atom_entity_generator
          AtomEntityGenerator.new(entity_manifest)
        end

        def aggregate_entity_generator
          AggregateEntityGenerator.new(entity_manifest)
        end

        def dependencies
          @dependencies ||= Set[
           entity_generator,
           unloaded_entity_generator,
           loaded_entity_generator,
           atom_entity_generator,
           aggregate_entity_generator
         ]
        end
      end
    end
  end
end
