require_relative "../command_generator"

module Foobara
  module RemoteGenerator
    module Generators
      module Auth
        class RequiresAuthGenerator < CommandGenerator
          def base_class_path
            "Foobara/Auth/RequiresAuthCommand"
          end

          def dependencies
            super.reject do |generator|
              generator.is_a?(RemoteCommandGenerator)
            end + [RequiresAuthCommandGenerator.new(relevant_manifest)]
          end
        end
      end
    end
  end
end
