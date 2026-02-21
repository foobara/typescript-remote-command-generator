module Foobara
  module RemoteGenerator
    module Generators
      module Auth
        class LogoutGenerator < CommandGenerator
          def base_class_path
            "Foobara/Auth/LogoutCommand"
          end

          def dependencies
            super.reject do |generator|
              generator.is_a?(RemoteCommandGenerator)
            end + [LogoutCommandGenerator.new(relevant_manifest)]
          end
        end
      end
    end
  end
end
