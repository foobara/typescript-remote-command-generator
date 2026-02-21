require_relative "../typescript_from_manifest_base_generator"

module Foobara
  module RemoteGenerator
    module Generators
      module Auth
        class RequiresAuthCommandGenerator < TypescriptFromManifestBaseGenerator
          def import_destructure
            ts_instance_path.first
          end

          def ts_instance_path
            ["RequiresAuthCommand"]
          end

          def ts_instance_full_path
            ["Foobara", "Auth", "RequiresAuthCommand"]
          end

          def template_path
            ["Foobara", "Auth", "RequiresAuthCommand.ts.erb"]
          end
        end
      end
    end
  end
end
