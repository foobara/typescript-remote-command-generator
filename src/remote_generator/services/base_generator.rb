module Foobara
  module RemoteGenerator
    class Services
      class BaseGenerator
        attr_accessor :relevant_manifest

        def initialize(relevant_manifest)
          self.relevant_manifest = relevant_manifest
        end

        def target_path
          raise "Subclass responsibility"
        end

        def generate
          # Render the template
          erb_template.result(binding)
        end

        def template_path
          raise "Subclass responsibility"
        end

        def absolute_template_path
          "#{__dir__}/../templates/#{template_path}"
        end

        def template_string
          File.read(absolute_template_path)
        end

        def erb_template
          ERB.new(template_string.gsub("\n<% end %>", "<% end %>"))
        end

        def short_name
          raise "Subclass responsibility"
        end

        foobara_delegate :organization_name,
                         :domain_name,
                         to: :relevant_manifest

        def domain_path
          path = []

          if organization_name != "global_organization"
            path << organization_name
          end

          if domain_name != "global_domain"
            path << domain_name
          end

          path
        end

        def path_to_root
          parts = ["../"] * (target_path.size - 1)
          parts.join
        end

        def import_path
          if target_path.last == "index.ts"
            target_path[0..-2]
          else
            target_path
          end.join("/")
        end

        def method_missing(method_name, *, &)
          if relevant_manifest.respond_to?(method_name)
            relevant_manifest.send(method_name, *, &)
          else
            super
          end
        end

        def respond_to_missing?(method_name, include_private = false)
          relevant_manifest.respond_to?(method_name, include_private)
        end

        # TODO: move this to a mixin somehow?
        def inspect
          manifest_data = relevant_manifest.to_h do |key, value|
            if value.is_a?(::Array)
              if value.size > 5 || value.any? { |v| _structure?(v) }
                value = "..."
              end
            elsif value.is_a?(::Hash)
              if value.size > 3 || value.keys.any? { |k| !k.is_a?(::Symbol) && !k.is_a?(::String) }
                value = "..."
              elsif value.values.any? { |v| _structure?(v) }
                value = "..."
              end
            end

            if key.is_a?(::String)
              key = key.to_sym
            end

            [key, value]
          end

          "#{target_path.inspect}: #{manifest_data.inspect}"
        end

        def _structure?(object)
          object.is_a?(::Hash) || object.is_a?(::Array)
        end
      end
    end
  end
end

=begin
import {writeToFile} from "./utils/fs";
import {CommandManifest, DomainManifest, EntityManifest, Manifest} from "../Manifest";
import {getGlobalManifest, getTargetDir} from "./globalManifest";
import {toPath} from "./utils/foobara";

export abstract class BaseGenerator<ManifestT> {
  relevantManifest: ManifestT
  get targetDir(): string {
    return getTargetDir()
  }

  get rootManifest () {
    return getGlobalManifest()
  }

  constructor(relevantManifest: ManifestT) {
    this.relevantManifest = relevantManifest
  }

  abstract targetPath(): string[]

  abstract generate(): string;

  write() {
    writeToFile(this.targetPath(), this.generate());
  }

  get shortName():string {
    throw new Error('Subclass responsibility')
  }

  get domainName():string {
    throw new Error('Subclass responsibility')
  }

  get organizationName():string {
    throw new Error('Subclass responsibility')
  }

  get domainPath () {
    return toPath(this.organizationName, this.domainName)
  }

  get fullName():string {
    return [
      this.organizationName,
      this.domainName,
      this.shortName
    ].join("::")
  }



  entityNameToManifest(entityFullName: string): EntityManifest {
    const [organizationName, domainName, shortName] = this.splitFullName(entityFullName)

    return this.domainManifestFor(organizationName, domainName)["types"][shortName] as EntityManifest
  }

  commandNameToManifest(fullCommandName: string): CommandManifest {
    const [organizationName, domainName, shortName] = this.splitFullName(fullCommandName)

    return this.domainManifestFor(organizationName, domainName)["commands"][shortName]
  }

  domainManifestFor(organizationName: string, domainName: string): DomainManifest {
    return this.rootManifest["organizations"][organizationName]["domains"][domainName] as DomainManifest
  }

  splitFullName(fullName: string): string[] {
    const parts = fullName.split("::")

    let organizationName
    let domainName
    const shortName = parts[parts.length - 1]

    if (parts.length === 3) {
      organizationName = parts[0]
      domainName = parts[1]
    } else {
      organizationName = "global_organization"
      domainName = parts.length === 2 ? parts[0] : "global_domain"
    }

    return [organizationName, domainName, shortName]
  }

  nonGlobalNameParts () {
    const parts = []

    if (this.organizationName && this.organizationName !== "global_organization") {
      parts.push(this.organizationName)
    }

    if (this.domainName && this.domainName !== "global_domain") {
      parts.push(this.domainName)
    }

    return [...parts, this.shortName]
  }

  pathToTargetDir(): string {
    const parts = this.targetPath()

    let result = ""

    for (let i = 0; i < parts.length - 2; i++) {
      result += "../"
    }

    return result
  }

  pathToFoobaraRemote() {
    return this.pathToTargetDir() + "../foobara/remote"
  }
}
=end
