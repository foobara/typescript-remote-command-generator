module Foobara
  module RemoteGenerator
    class Services
      module Auth
        class LoginCommandGenerator < TypescriptFromManifestBaseGenerator
          def template_path
            "Foobara/Auth/LoginCommand.ts.erb"
          end

          def dependencies
            super + [AccessTokensGenerator.new(relevant_manifest)]
          end
        end
      end
    end
  end
end
