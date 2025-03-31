require_relative "typescript_from_manifest_base_generator"

module Foobara
  module RemoteGenerator
    class Services
      class CommandGenerator < TypescriptFromManifestBaseGenerator
        alias command_manifest relevant_manifest

        def target_path
          [*scoped_full_path, "index.ts"]
        end

        def template_path
          "Command.ts.erb"
        end

        def domain_generator
          @domain_generator ||= Services::DomainGenerator.new(domain)
        end

        foobara_delegate :organization_generator, :domain_name, :organization_name, to: :domain_generator

        def errors_in_this_namespace
          @errors_in_this_namespace ||= possible_errors.values.map(&:error).uniq.sort_by(&:error_name).select do |error|
            error.parent&.path&.map(&:to_s) == path.map(&:to_s)
          end.map do |error_manifest|
            Services::ErrorGenerator.new(error_manifest)
          end
        end

        def dependencies
          errors_in_this_namespace
        end

        def command_errors_index_generator
          Services::CommandErrorsIndexGenerator.new(command_manifest)
        end

        def base_class_path
          "base/RemoteCommand"
        end

        def base_class_name
          base_class_path.split("/").last
        end
      end
    end
  end
end
