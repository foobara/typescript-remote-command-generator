require_relative "base_generator"

module Foobara
  module RemoteGenerator
    class Services
      class CommandGenerator < BaseGenerator
        alias command_manifest relevant_manifest

        def target_path
          [*scoped_full_path, "index.ts"]
        end

        def template_path
          "Command.ts.erb"
        end

        def domain_generator
          @domain_generator ||= Services::DomainGenerator.new(domain, elements_to_generate)
        end

        foobara_delegate :organization_generator, :domain_name, :organization_name, to: :domain_generator

        def dependencies
          [domain_generator]
        end
      end
    end
  end
end
