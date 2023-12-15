require_relative "base_generator"

module Foobara
  module RemoteGenerator
    class Services
      class ProcessorClassGenerator < BaseGenerator
        alias processor_class_manifest relevant_manifest

        def target_path
          *path, basename = scoped_full_path
          basename = "#{scoped_short_name}.ts"

          ["base", "processors", *path, basename]
        end

        def template_path
          "ProcessorClass.ts.erb"
        end
      end
    end
  end
end
