module Foobara
  module RemoteGenerator
    class Services
      class EntityGenerator < ModelGenerator
        alias entity_manifest relevant_manifest

        def template_path
          ["Entity", "Ambiguous.ts.erb"]
        end

        def entity_name(...)
          model_name(...)
        end

        def unloaded_name(points = nil)
          *prefix, name = if points
                            scoped_full_path(points)
                          else
                            # TODO: test this
                            # :nocov:
                            scoped_path
                            # :nocov:
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
