module Foobara
  module RemoteGenerator
    module Generators
      module Auth
        class LogoutCommandGenerator < TypescriptFromManifestBaseGenerator
          def import_destructure
            ts_instance_path.first
          end

          def ts_instance_path
            ["LogoutCommand"]
          end

          def ts_instance_full_path
            ["Foobara", "Auth", "LogoutCommand"]
          end

          def template_path
            ["Foobara", "Auth", "LogoutCommand.ts.erb"]
          end

          def dependencies
            super + [AccessTokensGenerator.new(relevant_manifest)]
          end
        end
      end
    end
  end
end
