require_relative "typescript_from_manifest_base_generator"

module Foobara
  module RemoteGenerator
    class Services
      class CommandResultGenerator < TypescriptFromManifestBaseGenerator
        alias command_manifest relevant_manifest

        def result_type
          command_manifest.result_type
        end

        def target_path
          [*scoped_full_path, "Result.ts"]
        end

        def template_path
          "Command/Result.ts.erb"
        end

        def model_generators(type = result_type, initial = true)
          if type.entity?
            generator_class = if atom?
                                if initial
                                  AtomEntityGenerator
                                else
                                  UnloadedEntityGenerator
                                end
                              elsif aggregate?
                                AggregateEntityGenerator
                              else
                                EntityGenerator
                              end

            [generator_class.new(type.to_entity)]
          elsif type.model?
            generator_class = if atom?
                                AtomModelGenerator
                              elsif aggregate?
                                AggregateModelGenerator
                              else
                                ModelGenerator
                              end

            [generator_class.new(type.to_model)]
          elsif type.type.to_sym == :attributes
            type.attribute_declarations.values.map do |attribute_declaration|
              model_generators(attribute_declaration, false)
            end.flatten.uniq
          else
            # TODO: handle tuples, associative arrays, arrays
            []
          end
        end

        def type_generators
          @type_generators ||= begin
            type = result_type
            type = type.to_type if result_type.is_a?(Manifest::TypeDeclaration)

            if !type.builtin? && !type.model?
              # TODO: Test this!!
              # :nocov:
              [TypeGenerator.new(type)]
              # :nocov:
            else
              []
            end
          end
        end

        def atom?
          serializers&.any? { |s| s == "Foobara::CommandConnectors::Serializers::AtomicSerializer" }
        end

        def aggregate?
          serializers&.any? { |s| s == "Foobara::CommandConnectors::Serializers::AggregateSerializer" }
        end

        def association_depth
          if atom?
            AssociationDepth::ATOM
          elsif aggregate?
            AssociationDepth::AGGREGATE
          else
            AssociationDepth::AMBIGUOUS
          end
        end

        def dependencies
          model_generators + type_generators
        end
      end
    end
  end
end
