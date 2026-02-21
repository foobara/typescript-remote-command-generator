require_relative "typescript_from_manifest_base_generator"

module Foobara
  module RemoteGenerator
    module Generators
      class CommandGenerator < TypescriptFromManifestBaseGenerator
        alias command_manifest relevant_manifest

        def target_path
          [*scoped_full_path, "index.ts"]
        end

        def template_path
          "Command.ts.erb"
        end

        def domain_generator
          @domain_generator ||= DomainGenerator.new(domain)
        end

        def organization_generator = domain_generator.organization_generator
        def domain_name = domain_generator.domain_name
        def organization_name = domain_generator.organization_name

        def errors_in_this_namespace
          @errors_in_this_namespace ||= possible_errors.values.map(&:error).uniq.sort_by(&:error_name).select do |error|
            error.parent&.manifest_path&.map(&:to_s) == manifest_path.map(&:to_s)
          end.map do |error_manifest|
            ErrorGenerator.new(error_manifest)
          end
        end

        def dependencies
          [
            RemoteCommandGenerator.new(Manifest::RootManifest.new(root_manifest)),
            *queries_that_are_dirtied_by_this_command.keys
          ]
        end

        def will_define
          ts_instance_path
        end

        def command_errors_index_generator
          CommandErrorsIndexGenerator.new(command_manifest)
        end

        def base_class_path
          "base/RemoteCommand"
        end

        def base_class_name
          base_class_path.split("/").last
        end

        def result_json_requires_cast?
          # What types require a cast?
          # :date and :datetime, :model, custom type declaration (check #custom?)
          result_type && type_requires_cast?(result_type)
        end

        def queries_that_are_dirtied_by_this_command
          return {} if query?

          return @queries_that_are_dirtied_by_this_command if defined?(@queries_that_are_dirtied_by_this_command)

          command_result_type = result_type

          paths_to_data = nil

          if command_result_type
            command_result_type = command_result_type.to_type if command_result_type.is_a?(Manifest::TypeDeclaration)

            if command_result_type.detached_entity?
              paths_to_data = { command_result_type => [:outcome, :result, command_result_type.primary_key_name] }
            else
              result_type_associations = Manifest::Model.associations(command_result_type)

              unless result_type_associations.empty?
                data_path, entity_type = result_type_associations.to_a.first
                paths_to_data = { entity_type => [:outcome, :result, data_path, entity_type.primary_key_name] }
              end
            end
          end

          if paths_to_data.nil?
            if inputs_type
              inputs_associations = Manifest::Model.associations(inputs_type)

              unless inputs_associations.empty?
                data_path, entity_type = inputs_associations.to_a.first
                paths_to_data = { entity_type => [:inputs, *data_path] }
              end
            end
          end

          dirties = {}

          unless paths_to_data.nil?
            all_queries = Manifest::RootManifest.new(root_manifest).queries.map do |query|
              generator_for(query)
            end

            paths_to_data.each_pair do |entity_type, path|
              all_queries.each do |query|
                query_inputs_type = query.inputs_type

                if query_inputs_type
                  query_associations = Manifest::Model.associations(query_inputs_type)
                  query_associations.each_pair do |query_association_path, query_entity_class|
                    query_entity_class = query_entity_class.to_type if query_entity_class.is_a?(Manifest::TypeDeclaration)

                    if query_entity_class == entity_type
                      dirties[query] = [path, query_association_path]
                    end
                  end

                  next if dirties.key?(query)
                end

                query_result_type = query.result_type
                next unless query_result_type

                if query_result_type.is_a?(Manifest::TypeDeclaration) && query_result_type.reference?
                  query_result_type = query_result_type.to_type
                end

                if query_result_type == entity_type
                  dirties[query] = true
                else
                  entity_classes = Manifest::Model.associations(query_result_type).values.uniq

                  entity_classes.each do |query_entity_class|
                    query_entity_class = query_entity_class.to_type if query_entity_class.is_a?(Manifest::TypeDeclaration)

                    if query_entity_class == entity_type
                      dirties[query] = true
                      break
                    end
                  end
                end
              end
            end
          end

          @queries_that_are_dirtied_by_this_command = dirties
        end

        def queries_dirtied_without_inputs
          return @queries_dirtied_without_inputs if defined?(@queries_dirtied_without_inputs)

          queries_dirtied = []

          queries_that_are_dirtied_by_this_command.each_pair do |query, value|
            if value == true
              queries_dirtied << query
            end
          end

          @queries_dirtied_without_inputs = queries_dirtied
        end

        def queries_dirtied_with_inputs
          return @queries_dirtied_with_inputs if defined?(@queries_dirtied_with_inputs)

          dirtied_queries = {}

          queries_that_are_dirtied_by_this_command.each_pair do |query, value|
            if value != true
              dirtied_queries[query] = value
            end
          end

          @queries_dirtied_with_inputs = dirtied_queries
        end

        private

        def type_requires_cast?(type_declaration)
          if type_declaration.is_a?(Manifest::Attributes)
            return false unless type_declaration.has_attribute_declarations?
            return false if type_declaration.attribute_declarations.empty?

            type_declaration.attribute_declarations.values.any? do |attribute_declaration|
              type_requires_cast?(attribute_declaration)
            end
          elsif type_declaration.is_a?(Manifest::Array)
            element_type = type_declaration.element_type
            element_type && type_requires_cast?(element_type)
          else
            return true if type_declaration.model?

            type_symbol = type_declaration.type_symbol

            if type_symbol == :date || type_symbol == :datetime
              return true
            end

            if type_declaration.custom?
              type_declaration = type_declaration.to_type if type_declaration.is_a?(Manifest::TypeDeclaration)
              base_type = type_declaration.base_type
              type_requires_cast?(base_type)
            end
          end
        end
      end
    end
  end
end
