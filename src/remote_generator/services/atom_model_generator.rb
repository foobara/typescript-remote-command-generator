module Foobara
  module RemoteGenerator
    class Services
      class AtomModelGenerator < ModelGenerator
        class << self
          def new(relevant_manifest)
            return super unless self == AtomModelGenerator

            if relevant_manifest.entity?
              AtomEntityGenerator.new(relevant_manifest)
            elsif relevant_manifest.has_associations?
              super
            else
              ModelGenerator.new(relevant_manifest)
            end
          end
        end

        def target_path
          [*domain.scoped_full_path, "types", model_name, "Atom.ts"]
        end

        def template_path
          ["Model", "Atom.ts.erb"]
        end

        def model_generators
          types_depended_on.select(&:model?).map do |model|
            if model.entity?
              Services::UnloadedEntityGenerator.new(model)
            else
              Services::AtomModelGenerator.new(model)
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
