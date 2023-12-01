require_relative "base_generator"

module Foobara
  module RemoteGenerator
    class Services
      class CommandErrorGenerator < BaseGenerator
        alias command_manifest relevant_manifest

        def target_path
          if global?
            ["base", "errors", "#{error_name}.ts"]
          else
            [*domain_path, command_name, "Errors.ts"]
          end
        end

        def global?
          global_symbols.include?(symbol.to_sym)
        end

        def global_symbols
          %w[
            cannot_cast
            missing_required_attribute
            unexpected_attributes
          ]
        end

        def error_name
          Util.classify(symbol)
        end

        def template_path
          "Command/Errors.ts.erb"
        end

        def entity_generators
          raise "wtf"
        end
      end
    end
  end
end
