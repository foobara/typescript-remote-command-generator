module Foobara
  module RemoteGenerator
    class Services
      class AtomEntityGenerator < LoadedEntityGenerator
        def target_path
          [*domain_path, "entities", entity_name, "Atom.ts"]
        end

        def template_path
          ["Entity", "Atom.ts.erb"]
        end

        def entity_name(points = nil)
          *prefix, name = if points
                            scoped_full_path(points)
                          else
                            scoped_path
                          end

          [*prefix, "Atom#{name}"].join(".")
        end
      end
    end
  end
end
