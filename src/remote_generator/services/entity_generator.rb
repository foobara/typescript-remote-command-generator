require_relative "model_generator"

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

          # TODO: I think this should be just Name not LoadedName.
          # The ambiguous class could be called PotentiallyUnloadedName instead?
          # or maybe NameOrReference? And unloaded could be NameReference instead?
          [*prefix, "Loaded#{name}"].join(".")
        end

        def atom_name(points = nil)
          if has_associations?
            super
          else
            loaded_name(points)
          end
        end

        def aggregate_name(points = nil)
          if has_associations?
            super
          else
            loaded_name(points)
          end
        end

        def primary_key_name
          primary_key_attribute
        end

        def primary_key_ts_type
          foobara_type_to_ts_type(primary_key_type, dependency_group:)
        end

        def entity_name_downcase
          model_name_downcase
        end

        def attribute_names
          super - [primary_key_name]
        end

        def base_ts_class
          "Entity"
        end
      end
    end
  end
end
