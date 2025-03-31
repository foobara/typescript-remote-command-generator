module Foobara
  module RemoteGenerator
    class Services
      module Auth
        class LogoutCommandGenerator < TypescriptFromManifestBaseGenerator
          def template_path
            "Foobara/Auth/LogoutCommand.ts.erb"
          end

          def dependencies
            super + [AccessTokensGenerator.new(relevant_manifest)]
          end
        end
      end
    end
  end
end
