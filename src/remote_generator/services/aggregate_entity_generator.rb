require_relative "loaded_entity_generator"

module Foobara
  module RemoteGenerator
    class Services
      class AggregateEntityGenerator < LoadedEntityGenerator
        def target_path
          [*domain_path, "entities", entity_name, "Aggregate.ts"]
        end

        def template_path
          ["Entity", "Aggregate.ts.erb"]
        end

        def entity_generators
          types_depended_on.select(&:entity?).map do |entity|
            Services::AggregateEntityGenerator.new(entity, elements_to_generate)
          end
        end

        def attributes_type_ts_type
          aggregate_attributes_ts_type
        end

        def ts_instance_path
          *prefix, name = super
          [*prefix, "#{name}Aggregate"]
        end

        def ts_instance_full_path
          *prefix, name = super
          [*prefix, "#{name}Aggregate"]
        end
      end
    end
  end
end
