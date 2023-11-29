require_relative "base_generator"

module Foobara
  module RemoteGenerator
    class Services
      class CommandInputsGenerator < BaseGenerator
        alias command_manifest relevant_manifest

        def target_path
          [*domain_path, command_name, "Inputs.ts"]
        end

        def template_path
          "Command/Inputs.ts.erb"
        end

        def required?(attribute_name)
          inputs_type.required?(attribute_name)
        end

        def attribute_declarations
          inputs_type.attribute_declarations
        end

        def entity_generators
          entity_manifests = attribute_declarations.values.select(&:entity?).map do |attribute_declaration|
            type = find_type(attribute_declaration)
            Manifest::Entity.new(root_manifest, type.path)
          end

          entity_manifests.uniq.map do |entity_manifest|
            Services::EntityGenerator.new(entity_manifest)
          end
        end
      end
    end
  end
end
