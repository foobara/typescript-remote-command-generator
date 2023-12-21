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

        def entity_generators
          types_depended_on.select(&:entity?).map do |entity|
            Services::UnloadedEntityGenerator.new(entity, elements_to_generate)
          end
        end

        def ts_instance_path
          *prefix, name = super
          [*prefix, "#{name}Atom"].join(".")
        end
      end
    end
  end
end
