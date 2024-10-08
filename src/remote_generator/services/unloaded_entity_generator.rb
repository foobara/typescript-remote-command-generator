module Foobara
  module RemoteGenerator
    class Services
      class UnloadedEntityGenerator < EntityGenerator
        def target_path
          [*super[..-2], "Unloaded.ts"]
        end

        def template_path
          ["Entity", "Unloaded.ts.erb"]
        end

        def ts_instance_full_path
          *prefix, name = super
          [*prefix, "Unloaded#{name}"]
        end
      end
    end
  end
end
