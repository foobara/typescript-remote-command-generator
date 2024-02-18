require_relative "loaded_entity_generator"

module Foobara
  module RemoteGenerator
    class Services
      class AggregateEntityGenerator < LoadedEntityGenerator
        class << self
          def new(relevant_manifest, elements_to_generate)
            return super unless self == AggregateEntityGenerator

            if relevant_manifest.has_associations?
              super
            else
              LoadedEntityGenerator.new(relevant_manifest, elements_to_generate)
            end
          end
        end

        def target_path
          [*domain.scoped_full_path, "types", entity_name, "Aggregate.ts"]
        end

        def template_path
          ["Entity", "Aggregate.ts.erb"]
        end

        def model_generators
          types_depended_on.select(&:model?).map do |model|
            Services::AggregateModelGenerator.new(model, elements_to_generate)
          end
        end

        def attributes_type_ts_type
          aggregate_attributes_ts_type
        end

        def ts_instance_path
          *prefix, name = scoped_path
          [*prefix, "#{name}Aggregate"]
        end

        def ts_instance_full_path
          *prefix, name = scoped_full_path
          [*prefix, "#{name}Aggregate"]
        end
      end
    end
  end
end
