require_relative "base_generator"
require_relative "command_generator"

module Foobara
  module RemoteGenerator
    class Services
      class CommandErrorsGenerator < CommandGenerator
        alias command_manifest relevant_manifest

        def target_path
          [*scoped_full_path, "Errors.ts"]
        end

        def template_path
          "Command/Errors.ts.erb"
        end

        def error_generators
          @error_generators ||= error_types.values.map(&:error).uniq.map do |error|
            Services::ErrorGenerator.new(error, elements_to_generate)
          end
        end

        def error_type_union
          errors_in_this_namespace.map do |error|
            dependency_group.non_colliding_type(error)
          end.join(" |\n  ")
        end

        def dependencies
          error_generators
        end
      end
    end
  end
end
