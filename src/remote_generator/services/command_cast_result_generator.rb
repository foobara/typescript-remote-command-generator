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

        def model_generators(*args)
          return super if args.size == 2

          generators = super(result_type, true).select(&:model?)

          nested_model_generators = []

          generators.each do |generator|
            _models_reachable_from_declaration(generator.relevant_manifest).each do |model|
              generator_class = if model.detached_entity?
                                  if aggregate?
                                    AggregateEntityGenerator
                                  else
                                    UnloadedEntityGenerator
                                  end
                                elsif aggregate?
                                  AggregateModelGenerator
                                else
                                  AtomModelGenerator
                                end

              new_generator = generator_class.new(model)

              unless generators.any? do |g|
                g.relevant_manifest == model && g.class == new_generator.class
              end
                nested_model_generators << new_generator
              end
            end
          end

          generators + nested_model_generators
        end

        def atom?
          serializers&.any? { |s| s == "Foobara::CommandConnectors::Serializers::AtomicSerializer" }
        end

        def aggregate?
          serializers&.any? { |s| s == "Foobara::CommandConnectors::Serializers::AggregateSerializer" }
        end

        def dependencies
          model_generators
        end

        private

        # TODO: need to make use of initial?
        def cast_json_result_function_body(cast_tree = _construct_cast_tree(result_type), parent = "json")
          return if cast_tree.empty?

          result = []

          case cast_tree
          when CastTree
            result = cast_json_result_function_body(cast_tree.children, parent)

            type_declaration = cast_tree.declaration_to_cast

            if type_declaration
              result << _to_cast_expression(type_declaration, parent)
            end
          when ::Hash
            cast_tree.each_pair do |path_part, child_cast_tree|
              if path_part == :"#"
                if child_cast_tree.is_a?(::Hash)
                  result << "#{parent}?.forEach((element) => {"
                  result << cast_json_result_function_body(child_cast_tree, "element")
                  result << "}"
                elsif child_cast_tree.is_a?(::String)
                  value = child_cast_tree.gsub("$$", "element")
                  result << "#{parent}?.forEach((element, index, array) => {"
                  result << "array[index] = #{value}"
                  result << "}"
                elsif child_cast_tree.is_a?(CastTree)
                  asdf
                else
                  binding.pry
                  raise "wtf"
                end
              elsif child_cast_tree.is_a?(::Hash)
                result << "const #{path_part} = #{parent}[\"#{path_part}\"]"
                result << cast_json_result_function_body(child_cast_tree, path_part)
              elsif child_cast_tree.is_a?(::String)
                value = child_cast_tree.gsub("$$", child_cast_tree)
                result << "#{parent}[\"#{path_part}\"] = #{value}"
              elsif child_cast_tree.is_a?(CastTree)
                result << cast_json_result_function_body(child_cast_tree.children, path_part)
                result << _to_cast_expression(
                  child_cast_tree.declaration_to_cast,
                  parent: path_part
                )
              else
                binding.pry
                raise "wtf"
              end
            end
          when ::String
            value = cast_tree.gsub("$$", parent)
            result << "#{parent} = #{value}"
          else
            binding.pry
          end

          result.join("\n")
        end

        def _ts_cast_expression(type_declaration, value:, parent: nil, property: nil)
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
            ts_model_name = model_to_ts_model_name(type)
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
            return Set.new unless type_declaration.has_attribute_declarations?
            return Set.new if type_declaration.attribute_declarations.empty?

            models = Set.new

            type_declaration.attribute_declarations.each_value do |attribute_declaration|
              if type_requires_cast?(attribute_declaration)
                models |= _models_reachable_from_declaration(attribute_declaration)
              end
            end

            models
          elsif type_declaration.is_a?(Manifest::Array)
            element_type = type_declaration.element_type

            if element_type && type_requires_cast?(element_type)
              _models_reachable_from_declaration(element_type)
            end || Set.new
          elsif type_declaration.model?
            if type_declaration.is_a?(Manifest::TypeDeclaration)
              type_declaration = type_declaration.to_type
            end

            Set[type_declaration]
          elsif type_declaration.custom?
            if type_requires_cast?(type_declaration.base_type.to_type_declaration)
              _models_reachable_from_declaration(type_declaration.base_type.to_type_declaration)
            end || Set.new
          else
            Set.new
          end
        end
      end
    end
  end
end
