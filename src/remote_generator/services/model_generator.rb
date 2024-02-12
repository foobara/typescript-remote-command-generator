require_relative "base_generator"

module Foobara
  module RemoteGenerator
    class Services
      class ModelGenerator < BaseGenerator
        class << self
          def new(relevant_manifest, elements_to_generate)
            return super unless self == ModelGenerator

            if relevant_manifest.entity?
              EntityGenerator.new(relevant_manifest, elements_to_generate)
            else
              super
            end
          end
        end

        alias model_manifest relevant_manifest

        def target_path
          [*domain_path, "types", model_name, "#{model_name}.ts"]
        end

        def template_path
          ["Model", "Model.ts.erb"]
        end

        def scoped_full_path(points = nil)
          full_path = model_manifest.scoped_full_path

          if points
            start_at = full_path.size - points - 1
            full_path[start_at..]
          else
            full_path
          end
        end

        def model_name(points = nil)
          if points
            scoped_full_path(points).join(".")
          else
            scoped_path.join(".")
          end
        end

        # Do models have associations??
        def atom_name(points = nil)
          if has_associations?
            *prefix, name = if points
                              scoped_full_path(points)
                            else
                              scoped_path
                            end

            [*prefix, "#{name}Atom"].join(".")
          else
            model_name(points)
          end
        end

        def aggregate_name(points = nil)
          if has_associations?
            *prefix, name = if points
                              scoped_full_path(points)
                            else
                              scoped_path
                            end

            [*prefix, "#{name}Aggregate"].join(".")
          else
            model_name(points)
          end
        end

        def model_generators
          types_depended_on.select(&:model?).map do |model|
            if model.entity?
              Services::EntityGenerator.new(model, elements_to_generate)
            else
              Services::ModelGenerator.new(model, elements_to_generate)
            end
          end
        end

        def dependencies
          model_generators
        end

        def model_name_downcase
          model_name[0].downcase + model_name[1..]
        end

        def attributes_type_ts_type
          association_depth = AssociationDepth::AMBIGUOUS
          foobara_type_to_ts_type(attributes_type, association_depth:, dependency_group:)
        end

        def atom_attributes_ts_type
          association_depth = AssociationDepth::ATOM
          foobara_type_to_ts_type(attributes_type, association_depth:, dependency_group:)
        end

        def aggregate_attributes_ts_type
          association_depth = AssociationDepth::AGGREGATE
          foobara_type_to_ts_type(attributes_type, association_depth:, dependency_group:)
        end

        def association_property_names_ts_array
          associations.keys.map(&:to_s).inspect
        end

        def attribute_names
          attributes_type.attribute_names
        end

        def base_ts_class
          "Model"
        end
      end
    end
  end
end
