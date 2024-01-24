require_relative "organization_generator"

module Foobara
  module RemoteGenerator
    class Services
      class OrganizationConfigGenerator < OrganizationGenerator
        def target_path
          [*super[0..-2], "config.ts"]
        end

        def template_path
          "Organization/config.ts.erb"
        end

        def dependencies
          []
        end
      end
    end
  end
end
