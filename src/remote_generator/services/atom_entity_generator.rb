module Foobara
  module RemoteGenerator
    class Services
      class AtomEntityGenerator < LoadedEntityGenerator
        class << self
          def new(relevant_manifest, elements_to_generate)
            if relevant_manifest.has_associations?
              super
            else
              LoadedEntityGenerator.new(relevant_manifest, elements_to_generate)
            end
          end
        end

        def target_path
          [*domain_path, "types", entity_name, "Atom.ts"]
        end

        def template_path
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
