require_relative "typescript_from_manifest_base_generator"
require_relative "type_generator"

module Foobara
  module RemoteGenerator
    class Services
      class ModelGenerator < TypeGenerator
        class << self
          def new(relevant_manifest)
            return super unless self == ModelGenerator

            if relevant_manifest.detached_entity?
              EntityGenerator.new(relevant_manifest)
            else
              super
            end
          end
        end

        alias model_manifest relevant_manifest

        def target_path
          [*domain.scoped_full_path, "Types", *model_prefix, model_short_name, "#{model_short_name}.ts"]
        end

        def ts_instance_path
          [*model_prefix, scoped_short_name]
        end

        def model_short_name
          type_short_name
        end

        def template_path
          ["Model", "Model.ts.erb"]
        end

        def model_prefix
          type_prefix
        end

        def model_name(points = nil)
          type_name(points)
        end

        def model_name_downcase
          type_name_downcase
        end
      end
    end
  end
end
