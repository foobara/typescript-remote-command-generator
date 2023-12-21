module Foobara
  module RemoteGenerator
    class Services
      class EntityVariantsGenerator < EntityGenerator
        def target_path
          [*domain_path, "entities", "#{entity_name}.ts"]
        end

        def template_path
          "EntityVariants.ts.erb"
        end

        def entity_generator
          EntityGenerator.new(entity_manifest, elements_to_generate)
        end

        def unloaded_entity_generator
          UnloadedEntityGenerator.new(entity_manifest, elements_to_generate)
        end

        def loaded_entity_generator
          LoadedEntityGenerator.new(entity_manifest, elements_to_generate)
        end

        def atom_entity_generator
          AtomEntityGenerator.new(entity_manifest, elements_to_generate)
        end

        def aggregate_entity_generator
          AggregateEntityGenerator.new(entity_manifest, elements_to_generate)
        end

        def dependencies
          [
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