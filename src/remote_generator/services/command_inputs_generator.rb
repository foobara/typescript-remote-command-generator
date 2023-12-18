require_relative "base_generator"

module Foobara
  module RemoteGenerator
    class Services
      class CommandInputsGenerator < BaseGenerator
        alias command_manifest relevant_manifest

        def target_path
          [*scoped_full_path, "Inputs.ts"]
        end

        def template_path
          "Command/Inputs.ts.erb"
        end

        def required?(attribute_name)
          inputs_type.required?(attribute_name)
        end

        def attribute_declarations
          inputs_type.attribute_declarations
        end

        def entity_generators
          inputs_types_depended_on.select(&:entity?).map do |entity|
            Services::EntityGenerator.new(entity, elements_to_generate)
          end
        end
      end
    end
  end
end
