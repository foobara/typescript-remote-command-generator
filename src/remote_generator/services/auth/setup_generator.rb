module Foobara
  module RemoteGenerator
    class Services
      module Auth
        class SetupGenerator < TypescriptFromManifestBaseGenerator
          def applicable?
            relevant_manifest.commands.any? do |command_manifest|
              command_manifest.full_command_name =~ /\bGetCurrentUser$/
            end
          end

          def template_path
            "setup.ts.erb"
          end
        end
      end
    end
  end
end
