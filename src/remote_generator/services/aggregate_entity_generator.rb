require_relative "loaded_entity_generator"

module Foobara
  module RemoteGenerator
    class Services
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
          types_depended_on.select(&:model?).map do |model|
            Services::AggregateModelGenerator.new(model)
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

        def import_destructure
          "{ #{scoped_short_name}Aggregate }"
        end
      end
    end
  end
end
