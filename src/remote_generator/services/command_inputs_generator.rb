require_relative "base_generator"

module Foobara
  module RemoteGenerator
    class Services
      class CommandInputsGenerator < BaseGenerator
        alias command_manifest relevant_manifest

        def target_path
          [*scoped_full_path, "Inputs.ts"]
        end

        def template_path
          "Command/Inputs.ts.erb"
        end

        def model_generators
          @model_generators ||= inputs_types_depended_on.select(&:model?).uniq.map do |model|
            if model.entity?
              Services::EntityGenerator.new(model, elements_to_generate)
            else
              Services::ModelGenerator.new(model, elements_to_generate)
            end
          end
        end

        def dependencies
          model_generators
        end
      end
    end
  end
end
