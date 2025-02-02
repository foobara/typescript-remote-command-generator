module Foobara
  module RemoteGenerator
    class Services
      class AtomEntityGenerator < LoadedEntityGenerator
        class << self
          def new(relevant_manifest)
            return super unless self == AtomEntityGenerator

            if relevant_manifest.has_associations?
              super
            else
              LoadedEntityGenerator.new(relevant_manifest)
            end
          end
        end

        def target_path
          [*super[..-2], "Atom.ts"]
        end

        def template_path
          ["Entity", "Atom.ts.erb"]
        end

        def model_generators
          types_depended_on.select(&:model?).map do |model|
            if model.detached_entity?
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
