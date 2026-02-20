require_relative "domain_generator"

module Foobara
  module RemoteGenerator
    module Generators
      class DomainConfigGenerator < DomainGenerator
        def target_path
          [*super[0..-2], "config.ts"]
        end

        def template_path
          "Domain/config.ts.erb"
        end

        def dependencies
          []
        end
      end
    end
  end
end
