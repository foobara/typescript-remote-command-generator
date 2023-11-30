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

        def unloaded_name
          "Unloaded#{entity_name}"
        end

        def atom_name
          if has_associations?
            "#{entity_name}Atom"
          else
            entity_name
          end
        end

        def aggregate_name
          if has_associations?
            "#{entity_name}Aggregate"
          else
            entity_name
          end
        end
      end
    end
  end
end
