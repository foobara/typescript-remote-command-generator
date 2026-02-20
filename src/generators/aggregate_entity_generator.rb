require_relative "loaded_entity_generator"

module Foobara
  module RemoteGenerator
    module Generators
      class AggregateEntityGenerator < LoadedEntityGenerator
        class << self
          def new(relevant_manifest)
            return super unless self == AggregateEntityGenerator

            if relevant_manifest.has_associations?
              super
            else
              LoadedEntityGenerator.new(relevant_manifest)
            end
          end
        end

        def target_path
          [*super[..-2], "Aggregate.ts"]
        end

        def template_path
          ["Entity", "Aggregate.ts.erb"]
        end

        def model_generators
          @model_generators ||= types_depended_on.select(&:model?).map do |model|
            AggregateModelGenerator.new(model)
          end
        end

        def dependencies
          [*super, superclass_generator]
        end

        def superclass_generator
          @superclass_generator ||= LoadedEntityGenerator.new(relevant_manifest)
        end

        def attributes_type_ts_type
          aggregate_attributes_ts_type
        end

        def ts_instance_path
          [*model_prefix, generated_type]
        end

        def generated_type
          "#{scoped_short_name}Aggregate"
        end
      end
    end
  end
end
