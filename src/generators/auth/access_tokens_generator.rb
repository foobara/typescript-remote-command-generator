module Foobara
  module RemoteGenerator
    module Generators
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
