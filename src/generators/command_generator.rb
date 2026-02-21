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
          errors_in_this_namespace
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
          # We can assume that any records we take as input are dirtied, just to be safe
          # It's fine to consider a query dirtied even when it isn't and a user can tweak the list
          # after-the-fact.
          # So once we have that list of entity classes, we can iterate over all queries
          # to see which take those entity classes as input or return those entity classes.
          # In the case of taking them as input, we'll create this with inputs pointing to that record.
          # Otherwise, in the case of returning records only we'll just dirty the query regardless of
          # inputs by setting the filter to `undefined`.
          inputs_associations = Manifest::Model.associations(inputs_type)

          dirties = {}

          inputs_associations.values.uniq do |entity_class|
            all_queries.each do |query|
              entity_classes = Manifest::Model.associations(query.result_type).values.uniq

              if entity_classes.include?(entity_class)
                dirties[query] = true
              end
            end
          end

          inputs_associations.each_pair do |data_path, entity_class|
            all_queries.each do |query|
              next if dirties[query] == true

              query_associations = Manifest::Model.associations(query.result_type)
              query_associations.each_pair do |query_association_path, query_entity_class|
                if query_entity_class == entity_class
                  filters[query] ||= {}
                  filters[query][query_association_path] = data_path
                end
              end
            end
          end

          dirties
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
