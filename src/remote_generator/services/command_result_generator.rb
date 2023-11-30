require_relative "base_generator"

module Foobara
  module RemoteGenerator
    class Services
      class CommandResultGenerator < BaseGenerator
        alias command_manifest relevant_manifest

        def result_type
          command_manifest.result_type
        end

        def target_path
          [*domain_path, command_name, "Result.ts"]
        end

        def template_path
          "Command/Result.ts.erb"
        end

        def entity_generators(type = result_type)
          if type.entity?
            [EntityGenerator.new(type.to_entity)]
          elsif type.type.to_sym == :attributes
            type.attribute_declarations.values.map do |attribute_declaration|
              entity_generators(attribute_declaration)
            end.flatten
          else
            # TODO: handle tuples, associative arrays, arrays
            []
          end
        end
      end
    end
  end
end
