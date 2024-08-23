require_relative "typescript_from_manifest_base_generator"

module Foobara
  module RemoteGenerator
    class Services
      class TypeGenerator < TypescriptFromManifestBaseGenerator
        class << self
          def new(relevant_manifest)
            return super unless self == TypeGenerator

            if relevant_manifest.entity?
              EntityGenerator.new(relevant_manifest)
            elsif relevant_manifest.model?
              ModelGenerator.new(relevant_manifest)
            else
              super
            end
          end
        end

        alias type_manifest relevant_manifest

        def target_path
          [*domain.scoped_full_path, "Types", *type_prefix, "#{type_short_name}.ts"]
        end

        def type_short_name
          scoped_short_name
        end

        def template_path
          ["Type", "Type.ts.erb"]
        end

        def type_prefix
          path = scoped_prefix

          if path && !path.empty?
            if path.first == "Types"
              path[1..]
            else
              path
            end
          else
            []
          end
        end

        def scoped_full_path(points = nil)
          full_path = type_manifest.scoped_full_path

          if points
            start_at = full_path.size - points - 1
            full_path[start_at..]
          else
            full_path
          end
        end

        def type_name(points = nil)
          if points
            scoped_full_path(points).join(".")
          else
            scoped_path.join(".")
          end
        end

        def type_guts
          guts = if declaration_data.key?("one_of")
                   declaration_data["one_of"].map do |enum_item|
                     value_to_ts_value(enum_item)
                   end.join(" | ")
                 else
                   # :nocov:
                   raise "Haven't implemented other types yet"
                   # :nocov:
                 end

          if declaration_data["allows_nil"]
            # TODO: add a custom type to the fixture manifest that includes allows_nil
            # :nocov:
            guts += " | undefined"
            # :nocov:
          end

          guts
        end

        def model_generators
          @model_generators ||= types_depended_on.select(&:model?).map do |model|
            Services::ModelGenerator.new(model)
          end
        end

        def custom_type_generators
          @custom_type_generators ||= types_depended_on.reject(&:builtin?).reject(&:model?).map do |type|
            Services::TypeGenerator.new(type)
          end
        end

        def dependencies
          custom_type_generators + model_generators
        end

        def type_name_downcase
          type_short_name[0].downcase + type_short_name[1..]
        end

        def attributes_type_ts_type
          association_depth = AssociationDepth::AMBIGUOUS
          foobara_type_to_ts_type(attributes_type, association_depth:, dependency_group:)
        end

        def atom_attributes_ts_type
          association_depth = AssociationDepth::ATOM
          foobara_type_to_ts_type(attributes_type, association_depth:, dependency_group:)
        end

        def aggregate_attributes_ts_type
          association_depth = AssociationDepth::AGGREGATE
          foobara_type_to_ts_type(attributes_type, association_depth:, dependency_group:)
        end

        def attribute_names
          attributes_type.attribute_names
        end
      end
    end
  end
end
