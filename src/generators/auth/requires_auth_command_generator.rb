require_relative "../typescript_from_manifest_base_generator"

module Foobara
  module RemoteGenerator
    class Services
      module Auth
        class RequiresAuthCommandGenerator < TypescriptFromManifestBaseGenerator
          def template_path
            "Foobara/Auth/RequiresAuthCommand.ts.erb"
          end
        end
      end
    end
  end
end
