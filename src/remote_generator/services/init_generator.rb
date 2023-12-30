require_relative "base_generator"

module Foobara
  module RemoteGenerator
    class Services
      class InitGenerator < BaseGenerator
        def target_path
          ["init.ts"]
        end

        def template_path
          "init.ts.erb"
        end

        def organization_generators
          @organization_generators ||= organizations.map do |organization_manifest|
            OrganizationGenerator.new(organization_manifest, elements_to_generate)
          end
        rescue => e
          binding.pry
          raise
        end

        def dependencies
          organization_generators
        end
      end
    end
  end
end
