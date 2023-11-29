require_relative "base_generator"

module Foobara
  module RemoteGenerator
    class TypeScriptGenerator
      class DomainGenerator < BaseGenerator
        alias domain_manifest relevant_manifest

        def target_path
          [*domain_path, "index.ts"]
        end

        def template_path
          "Domain.ts.erb"
        end
      end
    end
  end
end
