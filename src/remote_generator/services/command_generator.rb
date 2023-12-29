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

        def errors_in_this_namespace
          @errors_in_this_namespace ||= error_types.values.map(&:error).uniq.select do |error|
            error.parent&.path&.map(&:to_s) == path.map(&:to_s)
          end.map do |error_manifest|
            Services::ErrorGenerator.new(error_manifest, elements_to_generate)
          end
        end

        def dependencies
          errors_in_this_namespace
        end
      end
    end
  end
end
