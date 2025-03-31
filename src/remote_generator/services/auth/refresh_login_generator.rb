module Foobara
  module RemoteGenerator
    class Services
      module Auth
        class RefreshLoginGenerator < CommandGenerator
          def base_class_path
            "Foobara/Auth/LoginCommand"
          end

          def dependencies
            super + [LoginCommandGenerator.new(relevant_manifest)]
          end
        end
      end
    end
  end
end
