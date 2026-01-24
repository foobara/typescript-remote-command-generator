require_relative "typescript_from_manifest_base_generator"

module Foobara
  module RemoteGenerator
    class Services
      class ErrorGenerator < TypescriptFromManifestBaseGenerator
        alias error_manifest relevant_manifest

        def target_path
          p = parent

          basename = "#{error_name}.ts".split("::")

          prefix = case p
                   when OrganizationGenerator, DomainGenerator, CommandGenerator
                     [*p.target_dir, "errors"]
                   when TypeGenerator
                     [*p.target_dir, p.type_short_name, "errors"]
                   when nil
                     # :nocov:
                     raise "Expected #{error_name} to have a parent but it did not"
                   # :nocov:
                   else
                     p.target_dir
                   end

          [*prefix, *basename]
        end

        def error_base_class
          case category
          when "data"
            "DataError"
          else
            "RuntimeError"
          end
        end

        def template_path
          "Error.ts.erb"
        end

        def context_type_declaration
          @context_type_declaration ||= Manifest::TypeDeclaration.new(
            root_manifest, [*manifest_path, :context_type_declaration]
          )
        end

        def context_ts_type
          if context_type_declaration.is_a?(Manifest::Attributes) && context_type_declaration.empty?
            # TODO: update other parts of the generator that disable the linting rule to use this instead...
            "Record<string, never>"
          else
            foobara_type_to_ts_type(context_type_declaration, dependency_group:)
          end
        end

        def dependencies
          @dependencies ||= types_depended_on.select { |type| type.detached_entity? || type.custom? || type.model? }
        end
      end
    end
  end
end
