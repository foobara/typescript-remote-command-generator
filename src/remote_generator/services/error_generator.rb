require_relative "typescript_from_manifest_base_generator"

module Foobara
  module RemoteGenerator
    class Services
      class ErrorGenerator < TypescriptFromManifestBaseGenerator
        alias error_manifest relevant_manifest

        def target_path
          p = parent

          basename = "#{error_name}.ts"

          case parent
          when OrganizationGenerator, DomainGenerator, CommandGenerator
            [*p.target_dir, "errors", basename]
          when nil
            # :nocov:
            raise "Expected #{error_name} to have a parent but it did not"
            # :nocov:
          else
            [*p.target_dir, basename]
          end
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
          @context_type_declaration ||= Manifest::TypeDeclaration.new(root_manifest, [*path, :context_type_declaration])
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
          # Why don't we need models and custom types?
          # what about detached_entity types?
          types_depended_on.select(&:entity?)
        end

        def ts_type_full_path
          if parent.is_a?(CommandGenerator)
            p = super.dup
            p[-2] += "Errors"
            p
          else
            super
          end
        end
      end
    end
  end
end
