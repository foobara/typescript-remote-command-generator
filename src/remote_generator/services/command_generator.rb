require_relative "typescript_from_manifest_base_generator"

module Foobara
  module RemoteGenerator
    class Services
      class CommandGenerator < TypescriptFromManifestBaseGenerator
        alias command_manifest relevant_manifest

        def target_path
          [*scoped_full_path, "index.ts"]
        end

        def template_path
          "Command.ts.erb"
        end

        def domain_generator
          @domain_generator ||= Services::DomainGenerator.new(domain)
        end

        foobara_delegate :organization_generator, :domain_name, :organization_name, to: :domain_generator

        def errors_in_this_namespace
          @errors_in_this_namespace ||= possible_errors.values.map(&:error).uniq.sort_by(&:error_name).select do |error|
            error.parent&.path&.map(&:to_s) == path.map(&:to_s)
          end.map do |error_manifest|
            Services::ErrorGenerator.new(error_manifest)
          end
        end

        def dependencies
          errors_in_this_namespace
        end

        def command_errors_index_generator
          Services::CommandErrorsIndexGenerator.new(command_manifest)
        end

        def base_class_path
          "base/RemoteCommand"
        end

        def base_class_name
          base_class_path.split("/").last
        end

        def result_json_requires_cast?
          # What types require a cast?
          # :date and :datetime, :model, custom type declaration (check #custom?)
          result_type && type_requires_cast?(result_type)
        end

        private

        def type_requires_cast?(type_declaration)
          if type_declaration.is_a?(Manifest::Attributes)
            return false unless type_declaration.has_attribute_declarations?
            return false if type_declaration.attribute_declarations.empty?

            type_declaration.attribute_declarations.values.any? do |attribute_declaration|
              type_requires_cast?(attribute_declaration)
            end
          elsif type_declaration.is_a?(Manifest::Array)
            element_type = type_declaration.element_type
            element_type && type_requires_cast?(element_type)
          else
            return true if type_declaration.model?

            type_symbol = type_declaration.type
            type_symbol = type_symbol.to_sym if type_symbol.is_a?(::Symbol)

            type_symbol == :date || type_symbol == :datetime

            if type_declaration.custom?
              type_requires_cast?(type_declaration.base_type.to_type_declaration)
            end
          end
        end
      end
    end
  end
end
