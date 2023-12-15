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
          @error_generators ||= error_types.values.map do |error_manifest|
            Services::CommandErrorGenerator.new(error_manifest, elements_to_generate)
          end
        end

        def instantiated_error_types_union
          error_generators.map do |error_generator|
            error_generator.instantiated_error_type
          end.join(" |\n  ")
        end

        def entity_generators
          raise "wtf"
        end
      end
    end
  end
end
