module Foobara
  module RemoteGenerator
    class Services
      module Auth
        class AccessTokensGenerator < TypescriptFromManifestBaseGenerator
          def template_path
            "Foobara/Auth/utils/accessTokens.ts.erb"
          end
        end
      end
    end
  end
end
