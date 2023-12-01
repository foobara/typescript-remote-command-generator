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

        def uniq_error_generators_by_symbol
          @uniq_error_generators_by_symbol ||= error_generators.group_by(&:symbol).values
        end

        def error_generators
          @error_generators ||= error_types.values.map do |error_manifest|
            Services::CommandErrorGenerator.new(error_manifest)
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
