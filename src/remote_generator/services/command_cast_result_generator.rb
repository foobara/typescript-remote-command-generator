require_relative "command_result_generator"

module Foobara
  module RemoteGenerator
    class Services
      class CommandCastResultGenerator < CommandResultGenerator
        class CastTree
          attr_accessor :children, :declaration_to_cast, :initial

          def initialize(children: nil, declaration_to_cast: nil, initial: false)
            self.children = children
            self.declaration_to_cast = declaration_to_cast
            self.initial = initial
          end

          def empty?
            (children.nil? || children.empty?) && declaration_to_cast.nil?
          end
        end

        alias command_manifest relevant_manifest

        def result_type
          command_manifest.result_type
        end

        def target_path
          [*scoped_full_path, "castJsonResult.ts"]
        end

        def template_path
          "Command/castJsonResult.ts.erb"
        end

        def applicable?
          result_json_requires_cast?
        end

        def nested_model_generators
          return @nested_model_generators if defined?(@nested_model_generators)

          nested_model_generators = []

          if result_type.detached_entity? && atom?
            declaration = result_type.is_a?(Manifest::TypeDeclaration) ? result_type.to_type : result_type
            return @nested_model_generators = Set[Services::AtomEntityGenerator.new(declaration)]
          end

          _models_reachable_from_declaration(result_type, initial: true)&.each do |model|
            generator_class = if atom?
                                if model.detached_entity?
                                  Services::UnloadedEntityGenerator
                                else
                                  Services::AtomModelGenerator
                                end
                              elsif aggregate?
                                Services::AggregateModelGenerator
                              else
                                Services::ModelGenerator
                              end

            new_generator = generator_class.new(model)

            unless nested_model_generators.any? do |g|
              g.relevant_manifest == model && g.class == new_generator.class
            end
              nested_model_generators << new_generator
            end
          end

          @nested_model_generators = nested_model_generators
        end

        def atom?
          serializers&.any? { |s| s == "Foobara::CommandConnectors::Serializers::AtomicSerializer" }
        end

        def aggregate?
          serializers&.any? { |s| s == "Foobara::CommandConnectors::Serializers::AggregateSerializer" }
        end

        def dependencies
          nested_model_generators
        end

        def cast_json_result_function
          "#{cast_json_result_function_body}\nreturn json"
        end

        private

        # TODO: need to make use of initial?
        def cast_json_result_function_body(
          cast_tree = _construct_cast_tree(result_type, initial: true),
          parent: "json",
          property: nil,
          value: parent
        )
          if cast_tree.nil? || cast_tree.empty?
            return
          end

          result = []

          case cast_tree
          when CastTree
            result << cast_json_result_function_body(cast_tree.children, parent: value)
            result << _ts_cast_expression(cast_tree, parent:, property:, value:)
          when ::Hash
            cast_tree.each_pair do |path_part, child_cast_tree|
              if path_part == :"#"
                result << "#{parent}?.forEach((element: any, index: number, array: any[]) => {"
                result << cast_json_result_function_body(child_cast_tree,
                                                         parent: "array",
                                                         property: "index",
                                                         value: "element")
                result << "})"
              elsif child_cast_tree.is_a?(::Hash)
                # TODO: either test this code path or delete it
                # :nocov:
                property = path_part =~ /\A\d+\z/ ? path_part.to_i : "\"#{path_part}\""

                result << cast_json_result_function_body(child_cast_tree,
                                                         parent:,
                                                         property:,
                                                         value: "#{parent}?.#{path_part}")
                # :nocov:
              elsif child_cast_tree.is_a?(CastTree)
                result << cast_json_result_function_body(child_cast_tree.children,
                                                         parent: "#{parent}?.#{path_part}")

                property = path_part =~ /\A\d+\z/ ? path_part.to_i : "\"#{path_part}\""
                result << _ts_cast_expression(child_cast_tree,
                                              parent:,
                                              property:,
                                              value: "#{parent}?.#{path_part}")
              else
                # :nocov:
                raise "Not sure how to handle a #{cast_tree.class}: #{cast_tree}"
                # :nocov:
              end
            end
          else
            # :nocov:
            raise "Not sure how to handle a #{cast_tree.class}: #{cast_tree}"
            # :nocov:
          end

          result.compact.join("\n")
        end

        def _ts_cast_expression(cast_tree, value:, parent: nil, property: nil)
          unless cast_tree.is_a?(CastTree)
            # :nocov:
            raise "Expected a CastTree but got a #{cast_tree.class}: #{cast_tree}"
            # :nocov:
          end

          type_declaration = cast_tree.declaration_to_cast

          return unless type_declaration

          lvalue = if parent
                     if property.nil?
                       parent
                     elsif property =~ /\A"(.*)"\z/
                       "#{parent}?.#{$1}"
                     else
                       "#{parent}?.[#{property}]"
                     end
                   else
                     # TODO: either test this path or raise
                     # :nocov:
                     value
                     # :nocov:
                   end

          type = if type_declaration.is_a?(Manifest::TypeDeclaration)
                   type_declaration.to_type
                 else
                   type_declaration
                 end

          type_symbol = type.type_symbol

          value ||= lvalue.dup
          lvalue = lvalue.gsub("?.[", "[").gsub("?.", ".")
          present_value = value.gsub("?.[", "[").gsub("?.", ".")

          expression = "if (#{value} !== undefined) {\n"

          expression += if type_symbol == :date || type_symbol == :datetime
                          "#{lvalue} = new Date(#{present_value})\n"
                        elsif type.model?
                          ts_model_name = model_to_ts_model_name(type,
                                                                 association_depth:,
                                                                 initial: cast_tree.initial)

                          "#{lvalue} = new #{ts_model_name}(#{present_value})\n"
                        else
                          # :nocov:
                          raise "Not sure how to cast type #{type} to a Typescript expression"
                          # :nocov:
                        end

          expression += "}"
        end

        def _construct_cast_tree(type_declaration, initial: false)
          if type_declaration.is_a?(Manifest::Attributes)
            return unless type_declaration.has_attribute_declarations?
            return if type_declaration.attribute_declarations.empty?

            path_tree = {}

            type_declaration.attribute_declarations.each_pair do |attribute_name, attribute_declaration|
              if type_requires_cast?(attribute_declaration)
                path_tree[attribute_name] = _construct_cast_tree(attribute_declaration)
              end
            end

            unless path_tree.empty?
              CastTree.new(children: path_tree, initial:)
            end
          elsif type_declaration.is_a?(Manifest::Array)
            element_type = type_declaration.element_type

            if element_type && type_requires_cast?(element_type)
              CastTree.new(initial:, children: { "#": _construct_cast_tree(element_type) })
            end
          elsif type_declaration.type.to_sym == :date || type_declaration.type.to_sym == :datetime
            CastTree.new(declaration_to_cast: type_declaration, initial:)
          elsif type_declaration.model?
            type_declaration = type_declaration.to_type

            children = if type_declaration.detached_entity? && atom?
                         nil
                       else
                         _construct_cast_tree(type_declaration.attributes_type)
                       end

            CastTree.new(children:, declaration_to_cast: type_declaration, initial:)
            # TODO: either test this code path or raise or delete it
            # :nocov:
          elsif type_declaration.custom?
            if type_requires_cast?(type_declaration.base_type.to_type_declaration)
              tree = _construct_cast_tree(type_declaration.base_type.to_type_declaration)

              if tree && !tree.empty?
                CastTree.new(children: tree, initial:)
              end
            end
          end
          # :nocov:
        end

        # TODO: Feels like similar complicated logic is popping up in many places? How to find/converge such logic
        def _models_reachable_from_declaration(type_declaration, initial: false)
          if type_declaration.is_a?(Manifest::Attributes)
            return unless type_declaration.has_attribute_declarations?
            return if type_declaration.attribute_declarations.empty?

            models = nil

            type_declaration.attribute_declarations.each_value do |attribute_declaration|
              if type_requires_cast?(attribute_declaration)
                additional = _models_reachable_from_declaration(attribute_declaration)

                if additional
                  if models
                    models |= additional
                  else
                    models = additional
                  end
                end
              end
            end

            models
          elsif type_declaration.is_a?(Manifest::Array)
            element_type = type_declaration.element_type

            if element_type && type_requires_cast?(element_type)
              _models_reachable_from_declaration(element_type)
            end
          elsif type_declaration.model?
            if type_declaration.is_a?(Manifest::TypeDeclaration)
              type_declaration = type_declaration.to_type
            end

            models = Set[type_declaration]

            if atom? && type_declaration.detached_entity?
              return models
            end

            additional = _models_reachable_from_declaration(type_declaration.attributes_type)

            if additional
              models |= additional
            end

            models
          elsif type_declaration.custom?
            # TODO: either test this code path or raise or delete it
            # :nocov:
            if type_requires_cast?(type_declaration.base_type.to_type_declaration)
              _models_reachable_from_declaration(type_declaration.base_type.to_type_declaration)
            end
            # :nocov:
          end
        end
      end
    end
  end
end
