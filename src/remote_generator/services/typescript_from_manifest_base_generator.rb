# Where to put files?
# let's examine an error...
# if an error belongs to a command, let's put it in <command path>/errors/<error_name>.ts
# if an error belongs to a domain, let's put it in <domain path>/errors/<error_name>.ts
# if an error belongs to an organization, let's put it in <organization path>/errors/<error_name>.ts
# if an error belongs to a base processor, let's put it in base/processors/<processor path>/<error_name>.ts
# if an error belongs to nothing, let's put it in errors/<error_name>.ts
#
# so what is the official logic?
# if parent is a domain or org or nil,
# then we need to insert "errors" before the last element in the scoped_path.
# This is to help make the commands more first-class.
# otherwise, the thing will already be out of site. We could prepend the path with "base" and <parent_category>.
#
# Might just be safer though to leverage the parent's target_dir.
#
# So that logic would be...
# if parent is domain, nil, or org:
# <parent_target_dir>/errors/<error_name>.ts
# else
# <parent_target_dir>/<error_name>.ts

module Foobara
  module RemoteGenerator
    class Services
      class TypescriptFromManifestBaseGenerator < Foobara::FilesGenerator
        class << self
          def manifest_to_generator_classes(manifest)
            case manifest
            when Manifest::Command
              [
                Services::CommandGenerator,
                Services::CommandInputsGenerator,
                Services::CommandResultGenerator,
                Services::CommandErrorsGenerator,
                Services::CommandErrorsIndexGenerator,
                Services::CommandManifestGenerator
              ]
            when Manifest::Domain
              [
                Services::DomainGenerator,
                Services::DomainConfigGenerator,
                Services::DomainManifestGenerator
              ]
            when Manifest::Organization
              [
                Services::OrganizationGenerator,
                Services::OrganizationConfigGenerator,
                Services::OrganizationManifestGenerator
              ]
            when Manifest::Entity
              [
                Services::EntityGenerator,
                Services::EntityVariantsGenerator,
                Services::EntityManifestGenerator
              ]
            when Manifest::Model
              [
                Services::ModelGenerator,
                Services::ModelVariantsGenerator,
                Services::ModelManifestGenerator
              ]
            when Manifest::Error
              Services::ErrorGenerator
            when Manifest::ProcessorClass
              Services::ProcessorClassGenerator
            when Manifest::RootManifest
              Services::RootManifestGenerator
            when Manifest::Type
              Services::TypeGenerator
            else
              # :nocov:
              raise "Not sure how build a generator for a #{manifest}"
              # :nocov:
            end
          end
        end

        def initialize(relevant_manifest)
          unless relevant_manifest.is_a?(Manifest::BaseManifest)
            # :nocov:
            raise ArgumentError, "Expected a Foobara::Manifest, got #{relevant_manifest.class}"
            # :nocov:
          end

          super
        end

        def templates_dir
          "#{__dir__}/../../../templates"
        end

        def parent
          if relevant_manifest.parent
            generator_for(relevant_manifest.parent)
          end
        end

        def dependency_group
          @dependency_group ||= begin
            generators = dependencies.map do |dependency|
              generator_for(dependency)
            end

            DependencyGroup.new(generators, name: scoped_full_path.join("."))
          end
        end

        def dependency_roots
          unless dependency_group
            # :nocov:
            raise "This generator was created without a " \
                  "dependency_group and therefore cannot call #{__method__}"
            # :nocov:
          end

          dependency_group.non_colliding_dependency_roots.sort_by(&:scoped_full_name)
        end

        def ts_instance_path
          scoped_path
        end

        def ts_instance_full_name
          ts_instance_full_path.join(".")
        end

        def ts_instance_full_path
          scoped_full_path
        end

        def ts_type_full_path
          ts_instance_full_path
        end

        foobara_delegate :organization_name,
                         :domain_name,
                         to: :relevant_manifest

        def import_path
          if import_path_array.size == 1
            "./#{import_path_array.first}"
          else
            import_path_array.join("/")
          end
        end

        def import_destructure
          "{ #{scoped_short_name} }"
        end

        def import_path_array
          path = if target_path.last == "index.ts"
                   target_path[0..-2]
                 else
                   target_path
                 end

          path[-1] = path.last.gsub(/\.ts$/, "")

          path
        end

        def value_to_ts_value(value)
          case value
          when ::String, Numeric
            value.inspect
          when ::Symbol
            value.to_s.inspect
          else
            # :nocov:
            raise "Not sure how to represent #{value} in typescript. Maybe implement it."
            # :nocov:
          end
        end

        # TODO: relocate this to a more reusable place
        def foobara_type_to_ts_type(
          type_declaration,
          dependency_group: self.dependency_group,
          name: nil,
          association_depth: AssociationDepth::AMBIGUOUS,
          initial: true
        )
          if type_declaration.is_a?(Manifest::Error)
            error_generator = generator_for(type_declaration)
            return dependency_group.non_colliding_type(error_generator)
          end

          type_string = if type_declaration.is_a?(Manifest::Attributes)
                          ts_type = attributes_to_ts_type(type_declaration, association_depth:, dependency_group:)

                          if name
                            return "interface #{name} #{ts_type}"
                          else
                            ts_type
                          end
                        elsif type_declaration.is_a?(Manifest::Array)
                          # TODO: which association_depth do we pass here?
                          ts_type = foobara_type_to_ts_type(
                            type_declaration.element_type,
                            association_depth:,
                            dependency_group:,
                            initial: false
                          )
                          "#{ts_type}[]"
                        else
                          type_symbol = type_declaration.type

                          case type_symbol
                          when "string", "boolean"
                            type_symbol
                          when "number", "integer", "float"
                            "number"
                          # TODO: should apply relevant processors to make email a real email type instead of "string"
                          when "symbol", "email"
                            "string"
                          when "duck"
                            "any"
                          when "datetime"
                            "Date"
                          else
                            if type_declaration.model?
                              model_to_ts_model_name(type_declaration, association_depth:, initial:)
                            elsif can_convert_type_declaration_to_ts_type?(type_declaration)
                              type = type_declaration.to_type

                              custom_type_to_ts_type_name(type)
                            end
                          end
                        end

          if type_string
            if type_declaration.one_of
              type_string = type_declaration.one_of.map(&:inspect).join(" | ")
            end

            if type_declaration.allows_nil?
              type_string = "#{type_string} | null"
            end

            name ? "#{name} = #{type_string}" : type_string
          else
            # :nocov:
            raise "Not sure how to convert #{type_declaration} to a TS type"
            # :nocov:
          end
        end

        def can_convert_type_declaration_to_ts_type?(type_declaration)
          type = type_declaration.to_type

          return false if BuiltinTypes.builtin_reference?(type.reference)

          allowed_keys = %w[type one_of allows_nil]

          declaration_data = type.declaration_data

          bad_keys = declaration_data.keys - allowed_keys

          return false unless bad_keys.empty?

          BuiltinTypes.builtin_reference?(declaration_data["type"])
        end

        def attributes_to_ts_type(attributes, dependency_group:, association_depth: AssociationDepth::AMBIGUOUS)
          guts = attributes.attribute_declarations.map do |attribute_name, attribute_declaration|
            "  #{attribute_name}#{"?" unless attributes.required?(attribute_name)}: #{
              foobara_type_to_ts_type(attribute_declaration, dependency_group:, association_depth:, initial: false)
            }"
          end.join("\n")

          "{\n#{guts}\n}"
        end

        def model_to_ts_model_name(model, association_depth: AssociationDepth::AMBIGUOUS, initial: true)
          model = model.to_type if model.is_a?(Manifest::TypeDeclaration)

          generator_class = case association_depth
                            when AssociationDepth::AMBIGUOUS
                              Services::ModelGenerator
                            when AssociationDepth::ATOM
                              if !initial && model.entity?
                                Services::UnloadedEntityGenerator
                              else
                                Services::AtomModelGenerator
                              end
                            when AssociationDepth::AGGREGATE
                              Services::AggregateModelGenerator
                            else
                              # :nocov:
                              raise "Bad association_depth: #{association_depth}"
                              # :nocov:
                            end

          generator = generator_class.new(model)

          dependency_group.non_colliding_type(generator)
        end

        def custom_type_to_ts_type_name(type)
          type = type.to_type if type.is_a?(Manifest::TypeDeclaration)
          generator = TypeGenerator.new(type)

          dependency_group.non_colliding_type(generator)
        end

        def ==(other)
          self.class == other.class && path == other.path && root_manifest == other.root_manifest
        end

        def hash
          path.hash
        end
      end
    end
  end
end
