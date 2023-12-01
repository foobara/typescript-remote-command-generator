require_relative "base_generator"

module Foobara
  module RemoteGenerator
    class Services
      class CommandErrorGenerator < BaseGenerator
        alias error_manifest relevant_manifest

        def target_path
          if global?
            ["base", "errors", "#{error_name}.ts"]
          else
            [*domain_path, command_name, "Errors.ts"]
          end
        end

        def command_name
          path[-3].to_s
        end

        def error_name
          Util.classify(symbol)
        end

        def template_path
          "Command/Errors.ts.erb"
        end

        def instantiated_error_type
          result = "#{error_name}<\"#{key}\""

          if _path.any? || runtime_path.any?
            result += ", #{_path.map(&:to_s).inspect}"
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
