module Foobara
  module RemoteGenerator
    class Services
      class ModelVariantsGenerator < ModelGenerator
        def target_path
          [*domain_path, "types", "#{model_name}.ts"]
        end

        def template_path
          "ModelVariants.ts.erb"
        end

        def model_generator
          ModelGenerator.new(model_manifest, elements_to_generate)
        end

        def atom_model_generator
          AtomModelGenerator.new(model_manifest, elements_to_generate)
        end

        def aggregate_model_generator
          AggregateModelGenerator.new(model_manifest, elements_to_generate)
        end

        def dependencies
          if has_associations?
            [model_generator]
          else
            [model_generator, atom_model_generator, aggregate_model_generator]
          end
        end
      end
    end
  end
end
