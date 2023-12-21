require_relative "base_generator"

module Foobara
  module RemoteGenerator
    class Services
      class ErrorGenerator < BaseGenerator
        alias error_manifest relevant_manifest

        def target_path
          p = parent

          basename = "#{error_name}.ts"

          case parent
          when OrganizationGenerator, DomainGenerator, CommandGenerator
            [*p.target_dir, "errors", basename]
          when nil
            ["errors", basename]
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
          foobara_type_to_ts_type(context_type_declaration)
        end

        def dependencies
          binding.pry
          raise "wtf"
        end
      end
    end
  end
end
