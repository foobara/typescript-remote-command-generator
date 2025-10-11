require_relative "command_result_generator"

module Foobara
  module RemoteGenerator
    class Services
      class CommandCastResultGenerator < CommandResultGenerator
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

        def type_generators
          []
        end

        def model_generators
          generators = super.select(&:model?)

          nested_model_generators = []

          generators.each do |generator|
            _models_reachable_from_declaration(generator.relevant_manifest).each do |model|
              generator_class = if type.detached_entity?
                                  if aggregate?
                                    AggregateEntityGenerator
                                  else
                                    UnloadedEntityGenerator
                                  end
                                elsif type.model?
                                  if aggregate?
                                    AggregateModelGenerator
                                  else
                                    AtomModelGenerator
                                  end
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
          model_generators
        end

        private

        # TODO: need to make use of initial?
        def cast_json_result_function_body(cast_tree = _construct_cast_tree(result_type), parent = "json")
          result = []

          if cast_tree.is_a?(::Hash)
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
                else
                  raise "wtf"
                end
              elsif child_cast_tree.is_a?(::Hash)
                result << "const #{path_part} = #{parent}[\"#{path_part}\"]"
                result << cast_json_result_function_body(child_cast_tree, path_part)
              elsif child_cast_tree.is_a?(::String)
                value = child_cast_tree.gsub("$$", child_cast_tree)
                result << "#{parent}[\"#{path_part}\"] = #{value}"
              else
                raise "wtf"
              end
            end
          elsif cast_tree.is_a?(::String)
            value = cast_tree.gsub("$$", parent)
            result << "#{parent} = #{value}"
          end

          result.join("\n")
        end

        def _construct_cast_tree(type_declaration)
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
              path_tree
            end
          elsif type_declaration.is_a?(Manifest::Array)
            element_type = type_declaration.element_type

            if element_type && type_requires_cast?(element_type)
              { "#": _construct_cast_tree(element_type) }
            end
          elsif type_declaration.type.to_sym == :date || type_declaration.type.to_sym == :datetime
            "new Date($$)"
          elsif type_declaration.model?
            ts_model_name = model_to_ts_model_name(type_declaration.to_type)

            "new #{ts_model_name}($$)"
          elsif type_declaration.custom?
            if type_requires_cast?(type_declaration.base_type.to_type_declaration)
              _construct_cast_tree(type_declaration.base_type.to_type_declaration)
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
            Set[type_declaration.to_type]
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
