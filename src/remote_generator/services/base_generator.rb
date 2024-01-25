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
    class << self
      def generators_for(manifest, elements_to_generate)
        generator_classes = case manifest
                            when Services::BaseGenerator
                              return Util.array(manifest)
                            when Manifest::Command
                              [
                                Services::CommandGenerator,
                                Services::CommandInputsGenerator,
                                Services::CommandResultGenerator,
                                Services::CommandErrorsGenerator
                              ]
                            when Manifest::Domain
                              [
                                Services::DomainGenerator,
                                Services::DomainConfigGenerator
                              ]
                            when Manifest::Organization
                              [
                                Services::OrganizationGenerator,
                                Services::OrganizationConfigGenerator
                              ]
                            when Manifest::Entity
                              [
                                Services::EntityGenerator,
                                Services::UnloadedEntityGenerator,
                                Services::LoadedEntityGenerator,
                                Services::AtomEntityGenerator,
                                Services::AggregateEntityGenerator,
                                Services::EntityVariantsGenerator
                              ]
                            when Manifest::Error
                              Services::ErrorGenerator
                            when Manifest::ProcessorClass
                              Services::ProcessorClassGenerator
                            when Manifest::RootManifest
                              Services::InitGenerator
                            else
                              # :nocov:
                              raise "Not sure how build a generator for a #{manifest}"
                              # :nocov:
                            end

        Util.array(generator_classes).map do |generator_class|
          generator_class.new(manifest, elements_to_generate)
        end
      end

      def generator_for(manifest, elements_to_generate = nil)
        generators_for(manifest, elements_to_generate).first
      end
    end

    class Services
      class BaseGenerator
        include TruncatedInspect

        attr_accessor :relevant_manifest, :elements_to_generate, :belongs_to_dependency_group

        def initialize(relevant_manifest, elements_to_generate = nil)
          self.relevant_manifest = relevant_manifest
          self.elements_to_generate = elements_to_generate
        end

        def target_path
          # :nocov:
          raise "Subclass responsibility"
          # :nocov:
        end

        def target_dir
          target_path[0..-2]
        end

        def parent
          if relevant_manifest.parent
            RemoteGenerator.generator_for(relevant_manifest.parent, elements_to_generate)
          end
        end

        def applicable?
          true
        end

        def dependencies
          # :nocov:
          raise "Subclass responsibility"
          # :nocov:
        end

        def dependency_group
          @dependency_group ||= begin
            generators = dependencies.map do |dependency|
              RemoteGenerator.generator_for(dependency, elements_to_generate)
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

        def generate
          unless elements_to_generate
            # :nocov:
            raise "This generator was created without elements_to_generate and therefore cannot be ran."
            # :nocov:
          end

          dependencies.each do |dependency|
            elements_to_generate << dependency
          end

          # Render the template
          erb_template.result(binding)
        end

        def generator_for(manifest)
          RemoteGenerator.generator_for(manifest)
        end

        def template_path
          # :nocov:
          raise "Subclass responsibility"
          # :nocov:
        end

        def absolute_template_path
          path = template_path

          if path.is_a?(::Array)
            path = path.join("/")
          end

          Pathname.new("#{__dir__}/../templates/#{path}").cleanpath.to_s
        end

        def template_string
          File.read(absolute_template_path)
        end

        def erb_template
          # erb = ERB.new(template_string.gsub("\n<% end %>", "<% end %>"))
          erb = ERB.new(template_string)
          erb.filename = absolute_template_path
          erb
        end

        def short_name
          # :nocov:
          raise "Subclass responsibility"
          # :nocov:
        end

        def ts_instance_name
          ts_instance_path.join(".")
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

        foobara_delegate :organization_name,
                         :domain_name,
                         to: :relevant_manifest

        def domain_path
          path = []

          if organization_name != "GlobalOrganization"
            path << organization_name
          end

          if domain_name != "GlobalDomain"
            path << domain_name
          end

          path
        end

        def path_to_root
          size = target_path.size - 1

          (["../"] * size).join
        end

        def import_path
          if import_path_array.size == 1
            "./#{import_path_array.first}"
          else
            import_path_array.join("/")
          end
        end

        def import_destructure
          "{ #{scoped_name} }"
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

        def method_missing(method_name, *, &)
          if relevant_manifest.respond_to?(method_name)
            relevant_manifest.send(method_name, *, &)
          else
            # :nocov:
            super
            # :nocov:
          end
        end

        def respond_to_missing?(method_name, include_private = false)
          relevant_manifest.respond_to?(method_name, include_private)
        end

        def foobara_type_to_ts_type(
          type_declaration,
          dependency_group:, name: nil,
          association_depth: AssociationDepth::AMBIGUOUS
        )
          if type_declaration.is_a?(Manifest::Attributes)
            ts_type = attributes_to_ts_type(type_declaration, association_depth:, dependency_group:)

            return name ? "interface #{name} #{ts_type}" : ts_type
          end

          if type_declaration.is_a?(Manifest::Array)
            # TODO: which association_depth do we pass here?
            ts_type = foobara_type_to_ts_type(type_declaration.element_type, dependency_group:)
            return "#{ts_type}[]"
          end

          if type_declaration.is_a?(Manifest::Error)
            error_generator = generator_for(type_declaration)
            return dependency_group.non_colliding_type(error_generator)
          end

          type_symbol = type_declaration.type

          type_string = case type_symbol
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
                          if type_declaration.entity?
                            entity_to_ts_entity_name(type_declaration, association_depth:)
                          end
                        end

          if type_string
            name ? "#{name} = #{type_string}" : type_string
          else
            # :nocov:
            raise "Not sure how to convert #{type_declaration} to a TS type"
            # :nocov:
          end
        end

        def attributes_to_ts_type(attributes, dependency_group:, association_depth: AssociationDepth::AMBIGUOUS)
          guts = attributes.attribute_declarations.map do |attribute_name, attribute_declaration|
            "  #{attribute_name}#{"?" unless attributes.required?(attribute_name)}: #{
              foobara_type_to_ts_type(attribute_declaration, dependency_group:, association_depth:)
            }"
          end.join("\n")

          "{\n#{guts}\n}"
        end

        def entity_to_ts_entity_name(entity, association_depth: AssociationDepth::AMBIGUOUS)
          entity = entity.to_entity if entity.is_a?(Manifest::TypeDeclaration)

          generator_class = case association_depth
                            when AssociationDepth::AMBIGUOUS
                              Services::EntityGenerator
                            when AssociationDepth::ATOM
                              Services::UnloadedEntityGenerator
                            when AssociationDepth::AGGREGATE
                              Services::AggregateEntityGenerator
                            else
                              # :nocov:
                              raise "Bad association_depth: #{association_depth}"
                              # :nocov:
                            end

          generator = generator_class.new(entity, elements_to_generate)

          dependency_group.non_colliding_type(generator)
        end

        def ==(other)
          self.class == other.class && path == other.path && root_manifest == other.root_manifest
        end

        def eql?(other)
          self == other
        end

        def hash
          path.hash
        end
      end
    end
  end
end
