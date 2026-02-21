module Foobara
  module RemoteGenerator
    module Generators
      module Auth
        class LoginGenerator < CommandGenerator
          def base_class_path
            "Foobara/Auth/LoginCommand"
          end

          def dependencies
            super.reject do |generator|
              generator.is_a?(RemoteCommandGenerator)
            end + [LoginCommandGenerator.new(relevant_manifest)]
          end
        end
      end
    end
  end
end
