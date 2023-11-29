require_relative "base_generator"

module Foobara
  module RemoteGenerator
    class Services
      class CommandInputsGenerator < BaseGenerator
        alias command_manifest relevant_manifest

        def target_path
          [*domain_path, command_name, "Inputs.ts"]
        end

        def template_path
          "Command/Inputs.ts.erb"
        end

        def required?(attribute_name)
          inputs_type.required
        end

        def attribute_declarations
          inputs_type.attribute_declarations
        end
      end
    end
  end
end
