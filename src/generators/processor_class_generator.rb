require_relative "typescript_from_manifest_base_generator"

module Foobara
  module RemoteGenerator
    module Generators
      class ProcessorClassGenerator < TypescriptFromManifestBaseGenerator
        alias processor_class_manifest relevant_manifest

        def target_path
          *path, basename = scoped_full_path
          basename = "#{basename}.ts"

          ["base", "processors", *path, basename]
        end
      end
    end
  end
end
