require_relative "base_generator"

module Foobara
  module RemoteGenerator
    class Services
      class ModelGenerator < BaseGenerator
        alias model_manifest relevant_manifest

        def target_path
          [*domain_path, "types", model_name, "Ambiguous.ts"]
        end

        def template_path
          ["Model", "Ambiguous.ts.erb"]
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
            loaded_name(points)
          end
        end

        def aggregate_name(points = nil)
          *prefix, name = if points
                            scoped_full_path(points)
                          else
                            scoped_path
                          end

          [*prefix, "#{name}Aggregate"].join(".")
        end

        def entity_generators
          types_depended_on.select(&:entity?).map do |entity|
            Services::EntityGenerator.new(entity, elements_to_generate)
          end
        end

        def dependencies
          entity_generators
        end

        def primary_key_name
          primary_key_attribute
        end

        def primary_key_ts_type
          foobara_type_to_ts_type(primary_key_type, dependency_group:)
        end

        def entity_name_downcase
          entity_name[0].downcase + entity_name[1..]
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
          attributes_type.attribute_names - [primary_key_name]
        end
      end
    end
  end
end
