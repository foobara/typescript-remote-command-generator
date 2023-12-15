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

        def template_path
          "Error.ts.erb"
        end
      end
    end
  end
end
