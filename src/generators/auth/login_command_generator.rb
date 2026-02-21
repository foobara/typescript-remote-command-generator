module Foobara
  module RemoteGenerator
    module Generators
      module Auth
        class LoginCommandGenerator < TypescriptFromManifestBaseGenerator
          def import_destructure
            ts_instance_path.first
          end

          def ts_instance_path
            ["LoginCommand"]
          end

          def ts_instance_full_path
            ["Foobara", "Auth", "LoginCommand"]
          end

          def template_path
            ["Foobara", "Auth", "LoginCommand.ts.erb"]
          end

          def dependencies
            super + [AccessTokensGenerator.new(relevant_manifest)]
          end
        end
      end
    end
  end
end
