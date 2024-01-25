require_relative "command_errors_generator"

module Foobara
  module RemoteGenerator
    class Services
      class CommandErrorsIndexGenerator < CommandErrorsGenerator
        alias command_manifest relevant_manifest

        def target_path
          [*super[0..-2], "errors", "index.ts"]
        end

        def template_path
          "Command/errors/index.ts.erb"
        end

        def dependencies
          []
        end

        def applicable?
          error_generators.any?
        end
      end
    end
  end
end
