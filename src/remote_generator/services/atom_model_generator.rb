module Foobara
  module RemoteGenerator
    class Services
      class AtomModelGenerator < ModelGenerator
        def target_path
          [*domain_path, "types", model_name, "Atom.ts"]
        end

        def template_path
          # TODO: change to Model
          ["Entity", "Atom.ts.erb"]
        end

        def model_generators
          types_depended_on.select(&:model?).map do |model|
            if model.entity?
              Services::UnloadedEntityGenerator.new(model, elements_to_generate)
            else
              Services::AtomModelGenerator.new(model, elements_to_generate)
            end
          end
        end

        def ts_instance_path
          *prefix, name = scoped_path
          [*prefix, "#{name}Atom"]
        end

        def ts_instance_full_path
          *prefix, name = scoped_full_path
          [*prefix, "#{name}Atom"]
        end
      end
    end
  end
end
