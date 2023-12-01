require_relative "base_generator"

module Foobara
  module RemoteGenerator
    class Services
      class CommandErrorsGenerator < BaseGenerator
        alias command_manifest relevant_manifest

        def target_path
          [*domain_path, command_name, "Errors.ts"]
        end

        def template_path
          "Command/Errors.ts.erb"
        end

        def entity_generators
          raise "wtf"
        end
      end
    end
  end
end
