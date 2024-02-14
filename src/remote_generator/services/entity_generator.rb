require_relative "model_generator"

module Foobara
  module RemoteGenerator
    class Services
      class EntityGenerator < ModelGenerator
        alias entity_manifest relevant_manifest

        def target_path
          [*domain_path, "types", entity_name, "Ambiguous.ts"]
        end

        def template_path
          ["Entity", "Ambiguous.ts.erb"]
        end

        def entity_name(...)
          model_name(...)
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

        def association_property_paths
          associations.keys.map(&:path).inspect
        end
      end
    end
  end
end
