require_relative "base_generator"

module Foobara
  module RemoteGenerator
    class Services
      class EntityGenerator < BaseGenerator
        alias entity_manifest relevant_manifest

        def target_path
          [*domain_path, "entities", entity_name, "index.ts"]
        end

        def template_path
          "Entity.ts.erb"
        end

        def scoped_full_path(points = nil)
          full_path = entity_manifest.scoped_full_path

          if points
            start_at = full_path.size - points - 1
            full_path[start_at..]
          else
            full_path
          end
        end

        def entity_name(points = nil)
          if points
            scoped_full_path(points).join(".")
          else
            scoped_path.join(".")
          end
        end

        def unloaded_name(points = nil)
          *prefix, name = if points
                            scoped_full_path(points)
                          else
                            scoped_path
                          end

          [*prefix, "Unloaded#{name}"].join(".")
        end

        # TODO: consider using User for loaded user instead of LoadedUser and so maybe
        # PotentiallyUnloadedUser for User?? (or some better name)
        def loaded_name(points = nil)
          *prefix, name = if points
                            scoped_full_path(points)
                          else
                            scoped_path
                          end

          [*prefix, "Loaded#{name}"].join(".")
        end

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
          if has_associations?
            *prefix, name = if points
                              scoped_full_path(points)
                            else
                              scoped_path
                            end

            [*prefix, "#{name}Aggregate"].join(".")
          else
            loaded_name(points)
          end
        end

        def all_names
          @all_names ||= if has_associations?
                           [name, unloaded_name, atom_name, aggregate_name]
                         else
                           [name, unloaded_name]
                         end
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
          foobara_type_to_ts_type(primary_key_type)
        end

        def entity_name_downcase
          entity_name[0].downcase + entity_name[1..]
        end

        def attributes_type_ts_type
          association_depth = AssociationDepth::AMBIGUOUS
          foobara_type_to_ts_type(attributes_type, association_depth:)
        end

        def atom_attributes_ts_type
          association_depth = AssociationDepth::ATOM
          foobara_type_to_ts_type(attributes_type, association_depth:)
        end

        def aggregate_attributes_ts_type
          association_depth = AssociationDepth::AGGREGATE
          foobara_type_to_ts_type(attributes_type, association_depth:)
        end

        def attributes_types_union
          attributes_types = if has_associations?
                               ["", "Atom", "Aggregate"]
                             else
                               [""]
                             end

          attributes_types.map! { |prefix| "#{entity_name}#{prefix}AttributesType" }

          attributes_types.join(" | ")
        end

        def association_property_names_ts_array
          attribute_names.inspect
        end

        def attribute_names
          attributes_type.attribute_names - [primary_key_name]
        end
      end
    end
  end
end
