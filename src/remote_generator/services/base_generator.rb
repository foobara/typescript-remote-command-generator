module Foobara
  module RemoteGenerator
    class TypeScriptGenerator
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
          ERB.new(template_string)
        end

        def short_name
          raise "Subclass responsibility"
        end

        foobara_delegate :organization_name,
                         :domain_name,
                         to: :relevant_manifest

        def domain_path
          to_path organization_name, domain_name
        end

        def path_to_root
          parts = ["../"] * (target_path.size - 1)
          parts.join
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
