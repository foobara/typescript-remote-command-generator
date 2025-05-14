module Foobara
  module RemoteGenerator
    class Services
      module Auth
        class SetupGenerator < CommandGenerator
          def template_path
            "setup.ts.erb"
          end

          def target_path
            ["setup.ts"]
          end

          def command_generator
            generator_for(command_manifest)
          end

          def dependencies
            [command_generator]
          end
        end
      end
    end
  end
end
