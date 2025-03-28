require_relative "entity_generator"

module Foobara
  module RemoteGenerator
    class Services
      class LoadedEntityGenerator < EntityGenerator
        def target_path
          [*super[..-2], "Loaded.ts"]
        end

        def template_path
          ["Entity", "Loaded.ts.erb"]
        end

        def ts_instance_path
          *prefix, name = super
          [*prefix, "Loaded#{name}"]
        end

        def ts_instance_full_path
          *prefix, name = super
          [*prefix, "Loaded#{name}"]
        end

        def import_destructure
          "{ Loaded#{scoped_short_name} }"
        end
      end
    end
  end
end
