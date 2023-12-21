require_relative "loaded_entity_generator"

module Foobara
  module RemoteGenerator
    class Services
      class AggregateEntityGenerator < LoadedEntityGenerator
        def target_path
          [*domain_path, "entities", entity_name, "Aggregate.ts"]
        end

        def template_path
          ["Entity", "Aggregate.ts.erb"]
        end
      end
    end
  end
end
