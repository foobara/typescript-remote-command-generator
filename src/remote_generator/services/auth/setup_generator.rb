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

          def dependencies
            [self]
          end
        end
      end
    end
  end
end
