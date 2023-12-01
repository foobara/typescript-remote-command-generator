module Foobara
  module RemoteGenerator
    class GenerateTypescript < Foobara::Command
      # TODO: give better sugar for specifying required inputs
      inputs raw_manifest: { type: :associative_array, required: true }

      # TODO: specify a better type?
      result :associative_array

      def execute
        generate_base_files
        generate_organizations
        generate_domains
        each_command do
          generate_command
          generate_command_inputs
          generate_command_result
          generate_command_errors
        end

        generate_generated_files_json

        paths_to_source_code
      end

      attr_accessor :command_manifest

      def manifest
        @manifest ||= Manifest::RootManifest.new(raw_manifest)
      end

      def paths_to_source_code
        @paths_to_source_code ||= {}
      end

      def generate_base_files
        Dir["#{templates_dir}/base/**/*.ts"].each do |file_path|
          pathname = Pathname.new(file_path)

          key = pathname.relative_path_from(templates_dir)

          paths_to_source_code[key.to_s] = File.read(file_path)
        end
      end

      def templates_dir
        "#{__dir__}/templates"
      end

      def generate_organizations
        organization_manifests.each do |organization_manifest|
          organization_generator = Services::OrganizationGenerator.new(organization_manifest)
          paths_to_source_code[organization_generator.target_path.join("/")] = organization_generator.generate
        end
      end

      def generate_domains
        domain_manifests.each do |domain_manifest|
          domain_generator = Services::DomainGenerator.new(domain_manifest)
          paths_to_source_code[domain_generator.target_path.join("/")] =
            domain_generator.generate
        end
      end

      def organization_manifests
        manifest.organizations
      end

      def domain_manifests
        manifest.domains
      end

      def each_command
        manifest.commands.each do |command_manifest|
          self.command_manifest = command_manifest
          yield
        end
      end

      def generate_command
        command_generator = Services::CommandGenerator.new(command_manifest)
        paths_to_source_code[command_generator.target_path.join("/")] = command_generator.generate
      end

      def generate_command_inputs
        command_inputs_generator = Services::CommandInputsGenerator.new(command_manifest)
        paths_to_source_code[command_inputs_generator.target_path.join("/")] = command_inputs_generator.generate
      end

      def generate_command_result
        command_result_generator = Services::CommandResultGenerator.new(command_manifest)
        paths_to_source_code[command_result_generator.target_path.join("/")] = command_result_generator.generate
      end

      def generate_command_errors
        command_errors_generator = Services::CommandErrorsGenerator.new(command_manifest)
        paths_to_source_code[command_errors_generator.target_path.join("/")] = command_errors_generator.generate
      end

      def generate_generated_files_json
        paths_to_source_code["foobara-generated.json"] = "[\n#{
          paths_to_source_code.keys.map { |k| "  \"#{k}\"" }.join(",\n")
        }\n]\n"
      end

      # def generate_and_write_all
      #   organization_manifests.each do |organization_manifest|
      #     organization_generator = OrganizationGenerator.new(organization_manifest)
      #     organization_generator.write
      #   end
      #
      #   domain_manifests.each do |domain_manifest|
      #     domain_generator = DomainGenerator.new(domain_manifest)
      #     domain_generator.write
      #   end
      #
      #   entity_manifests_to_generate.each do |entity_manifest|
      #     entity_generator = EntityGenerator.new(entity_manifest)
      #     entity_generator.write
      #   end
      #
      #   global_manifest.each do |organization_name, organization_manifest|
      #     organization_manifest.each do |domain_name, domain_manifest|
      #       # TODO: remove this check when we're ready to generate domains/commands that have Models/Entities
      #       next if domain_name == "Math"
      #
      #       domain_manifest.commands.each do |command_name, command_manifest|
      #         command_generator = CommandGenerator.new(command_manifest)
      #         command_generator.write
      #
      #         command_inputs_generator = CommandInputsGenerator.new(command_manifest)
      #         command_inputs_generator.write
      #
      #         result_generator = CommandResultGenerator.new(command_manifest)
      #         result_generator.write
      #
      #         error_types_generator = CommandErrorsGenerator.new(command_manifest)
      #         error_types_generator.write
      #       end
      #     end
      #  end
      # end
      #
      # TODO: move this to a mixin somehow?
      #
    end
  end
end
