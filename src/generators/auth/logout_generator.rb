module Foobara
  module RemoteGenerator
    class Services
      module Auth
        class LogoutGenerator < CommandGenerator
          def base_class_path
            "Foobara/Auth/LogoutCommand"
          end

          def dependencies
            super + [LogoutCommandGenerator.new(relevant_manifest)]
          end
        end
      end
    end
  end
end
