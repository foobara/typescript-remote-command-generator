module Foobara
  module RemoteGenerator
    class Services
      class AggregateModelGenerator < ModelGenerator
        class << self
          def new(relevant_manifest)
            return super unless self == AggregateModelGenerator

            if relevant_manifest.detached_entity?
              AggregateEntityGenerator.new(relevant_manifest)
            elsif relevant_manifest.has_associations?
              super
            else
              ModelGenerator.new(relevant_manifest)
            end
          end
        end

        def target_path
          [*super[..-2], "Aggregate.ts"]
        end

        def template_path
          ["Model", "Aggregate.ts.erb"]
        end

        def model_generators
          types_depended_on.select(&:model?).map do |model|
            if model.detached_entity?
              Services::AggregateEntityGenerator.new(model)
            else
              Services::AggregateModelGenerator.new(model)
            end
          end
        end

        def attributes_type_ts_type
          aggregate_attributes_ts_type
        end

        def ts_instance_full_path
          *prefix, name = scoped_full_path
          [*prefix, "#{name}Aggregate"]
        end
      end
    end
  end
end
