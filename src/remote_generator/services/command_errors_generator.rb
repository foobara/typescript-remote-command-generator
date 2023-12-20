require_relative "base_generator"

module Foobara
  module RemoteGenerator
    class Services
      class CommandErrorsGenerator < BaseGenerator
        alias command_manifest relevant_manifest

        def target_path
          [*scoped_full_path, "Errors.ts"]
        end

        def template_path
          "Command/Errors.ts.erb"
        end

        def uniq_error_generators_by_symbol
          @uniq_error_generators_by_symbol ||= begin
            set = {}

            error_generators.each do |error_generator|
              set[error_generator.symbol] = error_generator
            end

            set.values
          end
        end

        def error_generators
          error_types.values.map(&:error).uniq.map do |error|
            Services::ErrorGenerator.new(error, elements_to_generate)
          end
        end

        def dependencies
          error_generators
        end

        def instantiated_error_types_union
          error_types.keys.map do |key|
            instantiated_error_type(key)
          end.join(" |\n  ")
        end

        def instantiated_error_type(key)
          command_error = error_types[key]
          error = command_error.error
          path = command_error._path
          runtime_path = command_error.runtime_path

          result = "#{error.error_name}<\"#{key}\""

          if path.any? || runtime_path.any?
            result += ", #{path.map(&:to_s).inspect}"
          end

          if runtime_path.any?
            result += ", #{runtime_path.map(&:to_s).inspect}"
          end

          "#{result}>"
        end
      end
    end
  end
end
