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
          errors_in_this_namespace.any?
        end

        def import_destructure
          "* as #{scoped_name}Errors"
        end
      end
    end
  end
end
