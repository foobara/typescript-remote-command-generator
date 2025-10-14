require_relative "command_result_generator"

module Foobara
  module RemoteGenerator
    class Services
      class CommandCastResultGenerator < CommandResultGenerator
        class CastTree
          attr_accessor :children, :declaration_to_cast, :past_first_model

          def initialize(children: nil, declaration_to_cast: nil, past_first_model: false)
            self.children = children
            self.declaration_to_cast = declaration_to_cast
            self.past_first_model = past_first_model
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

          generators = model_generators

          generators.each do |generator|
            _models_reachable_from_declaration(generator.relevant_manifest)&.each do |model|
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

              unless generators.any? do |g|
                g.relevant_manifest == model && g.class == new_generator.class
              end
                nested_model_generators << new_generator
              end
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
          @dependencies ||= model_generators + nested_model_generators
        end

        def cast_json_result_function
          "#{cast_json_result_function_body}\nreturn json"
        end

        private

        # TODO: need to make use of initial?
        def cast_json_result_function_body(cast_tree = _construct_cast_tree(result_type), parent = "json")
          return if cast_tree.nil? || cast_tree.empty?

          result = []

          case cast_tree
          when CastTree
            result << cast_json_result_function_body(cast_tree.children, parent)
            result << _ts_cast_expression(cast_tree, value: parent)
          when ::Hash
            cast_tree.each_pair do |path_part, child_cast_tree|
              if path_part == :"#"
                result << "#{parent}?.forEach((element, index, array) => {"
                result << cast_json_result_function_body(child_cast_tree, "array[index]")
                result << "})"
              elsif child_cast_tree.is_a?(::Hash)
                result << cast_json_result_function_body(child_cast_tree, "#{parent}.#{path_part}")
              elsif child_cast_tree.is_a?(CastTree)
                result << cast_json_result_function_body(child_cast_tree.children, "#{parent}.#{path_part}")
                result << _ts_cast_expression(child_cast_tree, value: "#{parent}.#{path_part}")
              else
                raise "Not sure how to handle a #{cast_tree.class}: #{cast_tree}"
              end
            end
          else
            raise "Not sure how to handle a #{cast_tree.class}: #{cast_tree}"
          end

          result.compact.join("\n")
        end

        def _ts_cast_expression(cast_tree, value:, parent: nil, property: nil)
          unless cast_tree.is_a?(CastTree)
            raise "Expected a CastTree but got a #{cast_tree.class}: #{cast_tree}"
          end

          type_declaration = cast_tree.declaration_to_cast

          return unless type_declaration

          lvalue = if parent
                     "#{parent}[#{property}]"
                   else
                     value
                   end

          type = if type_declaration.is_a?(Manifest::TypeDeclaration)
                   type_declaration.to_type
                 else
                   type_declaration
                 end

          type_symbol = type.type_symbol

          value ||= lvalue

          if type_symbol == :date || type_symbol == :datetime
            "#{lvalue} = new Date(#{value})"
          elsif type.model?
            ts_model_name = model_to_ts_model_name(type, association_depth:,
                                                         initial: !cast_tree.past_first_model)

            "#{lvalue} = new #{ts_model_name}(#{value})"
          else
            raise "wtf"
          end
        end

        def _construct_cast_tree(type_declaration, past_first_model: false)
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
              CastTree.new(children: path_tree, past_first_model:)
            end
          elsif type_declaration.is_a?(Manifest::Array)
            element_type = type_declaration.element_type

            if element_type && type_requires_cast?(element_type)
              CastTree.new(children: { "#": _construct_cast_tree(element_type) }, past_first_model:)
            end
          elsif type_declaration.type.to_sym == :date || type_declaration.type.to_sym == :datetime
            CastTree.new(declaration_to_cast: type_declaration)
          elsif type_declaration.model?
            type_declaration = type_declaration.to_type

            children = _construct_cast_tree(type_declaration.attributes_type)
            CastTree.new(children:, declaration_to_cast: type_declaration, past_first_model: true)
          elsif type_declaration.custom?
            if type_requires_cast?(type_declaration.base_type.to_type_declaration)
              tree = _construct_cast_tree(type_declaration.base_type.to_type_declaration)

              if tree && !tree.empty?
                CastTree.new(children: tree, past_first_model:)
              end
            end
          end
        end

        def _models_reachable_from_declaration(type_declaration)
          if type_declaration.is_a?(Manifest::Attributes)
            return  unless type_declaration.has_attribute_declarations?
            return  if type_declaration.attribute_declarations.empty?

            models = nil

            type_declaration.attribute_declarations.each_value do |attribute_declaration|
              if type_requires_cast?(attribute_declaration)
                models ||= Set.new

                _models_reachable_from_declaration(attribute_declaration)&.each do |model|
                  models << model
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

            _models_reachable_from_declaration(type_declaration.attributes_type)&.each do |model|
              models << model
            end

            models
          elsif type_declaration.custom?
            if type_requires_cast?(type_declaration.base_type.to_type_declaration)
              _models_reachable_from_declaration(type_declaration.base_type.to_type_declaration)
            end
          end
        end
      end
    end
  end
end
