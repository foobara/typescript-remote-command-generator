require_relative "typescript_from_manifest_base_generator"

module Foobara
  module RemoteGenerator
    class Services
      class CommandInputsGenerator < TypescriptFromManifestBaseGenerator
        alias command_manifest relevant_manifest

        def target_path
          [*scoped_full_path, "Inputs.ts"]
        end

        def template_path
          "Command/Inputs.ts.erb"
        end

        # TODO: we should break the various TypeScript WhateverAttributesType and
        # WhateverPrimaryKeyType into separate generators with separate templates so
        # we can use those types instead of constructing new types from the attributes/primary keys
        # of models/entities.
        # Instead, for now, we will just translate input types to not have entities/models
        # by converting models to their attributes and entities to their primary keys.
        def model_and_entity_free_types_depended_on(types_to_consider = inputs_types_depended_on)
          types = []

          types_to_consider.each do |type|
            if type.is_a?(Manifest::TypeDeclaration)
              type = type.to_type
            end

            if type.detached_entity?
              types += model_and_entity_free_types_depended_on([type.primary_key_type])
            elsif type.model?
              types += model_and_entity_free_types_depended_on(type.types_depended_on)
            elsif !type.builtin?
              types << type
            end
          end

          types
        end

        def type_generators
          @type_generators ||= model_and_entity_free_types_depended_on.uniq.map do |type|
            TypeGenerator.new(type)
          end
        end

        def dependencies
          type_generators
        end
      end
    end
  end
end
