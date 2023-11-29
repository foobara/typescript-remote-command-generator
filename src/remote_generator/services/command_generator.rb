require_relative "base_generator"

module Foobara
  module RemoteGenerator
    class Services
      class CommandGenerator < BaseGenerator
        alias command_manifest relevant_manifest

        def target_path
          [*domain_path, command_name, "index.ts"]
        end

        def template_path
          "Command.ts.erb"
        end
      end
    end
  end
end
