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
          @error_generators ||= possible_errors.values.map(&:error).sort_by(&:error_name).uniq.map do |error|
            Services::ErrorGenerator.new(error, elements_to_generate)
          end
        end

        def error_type_union
          error_generators.map do |error_generator|
            dependency_group.non_colliding_type(error_generator)
          end.join(" |\n  ")
        end

        def dependencies
          error_generators
        end
      end
    end
  end
end
