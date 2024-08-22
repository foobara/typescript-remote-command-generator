require_relative "typescript_from_manifest_base_generator"

module Foobara
  module RemoteGenerator
    class Services
      class CommandInputsGenerator < TypescriptFromManifestBaseGenerator
        alias command_manifest relevant_manifest

        def target_path
          [*scoped_full_path, "Inputs.ts"]
        end

        def template_path
          "Command/Inputs.ts.erb"
        end

        def model_generators
          binding.pry
          type_generators.select do |type_generator|
            type_generator.is_a?(Services::ModelGenerator)
          end
        end

        def type_generators
          @type_generators ||= types_depended_on.reject(&:builtin?).map do |type|
            Services::TypeGenerator.new(type)
          end
        end

        def dependencies
          type_generators
        end
      end
    end
  end
end
