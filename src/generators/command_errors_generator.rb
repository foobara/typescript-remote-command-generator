require_relative "typescript_from_manifest_base_generator"
require_relative "command_generator"

module Foobara
  module RemoteGenerator
    module Generators
      class CommandErrorsGenerator < CommandGenerator
        alias command_manifest relevant_manifest

        def target_path
          [*scoped_full_path, "Errors.ts"]
        end

        def template_path
          "Command/Errors.ts.erb"
        end

        def has_possible_errors?
          error_generators.any?
        end

        def error_generators
          @error_generators ||= possible_errors.values.map(&:error).sort_by(&:error_name).uniq.map do |error|
            ErrorGenerator.new(error)
          end
        end

        def error_type_union
          return "never" unless has_possible_errors?

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
