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

        def ts_instance_path
          [*model_prefix, generated_type]
        end

        def generated_type
          "Unloaded#{scoped_short_name}"
        end
      end
    end
  end
end
