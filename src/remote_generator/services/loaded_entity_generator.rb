require_relative "entity_generator"

module Foobara
  module RemoteGenerator
    class Services
      class LoadedEntityGenerator < EntityGenerator
        def target_path
          [*domain_path, "entities", entity_name, "Loaded.ts"]
        end

        def template_path
          ["Entity", "Loaded.ts.erb"]
        end

        def entity_name(points = nil)
          *prefix, name = if points
                            scoped_full_path(points)
                          else
                            scoped_path
                          end

          [*prefix, "Loaded#{name}"].join(".")
        end
      end
    end
  end
end
