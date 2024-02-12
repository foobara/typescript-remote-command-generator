module Foobara
  module RemoteGenerator
    class Services
      class AggregateModelGenerator < ModelGenerator
        class << self
          def new(relevant_manifest, elements_to_generate)
            if relevant_manifest.entity?
              AggregateEntityGenerator.new(relevant_manifest, elements_to_generate)
            elsif relevant_manifest.has_associations?
              super
            else
              ModelGenerator.new(relevant_manifest, elements_to_generate)
            end
          end
        end

        def target_path
          [*domain_path, "types", entity_name, "Aggregate.ts"]
        end

        def template_path
          ["Model", "Aggregate.ts.erb"]
        end

        def model_generators
          types_depended_on.select(&:model?).map do |model|
            if model.entity?
              Services::AggregateEntityGenerator.new(model, elements_to_generate)
            else
              Services::AggregateModelGenerator.new(model, elements_to_generate)
            end
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
