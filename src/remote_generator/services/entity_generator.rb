require_relative "base_generator"

module Foobara
  module RemoteGenerator
    class Services
      class EntityGenerator < BaseGenerator
        alias entity_manifest relevant_manifest

        def target_path
          [*domain_path, "entities", entity_name, "index.ts"]
        end

        def template_path
          "Entity.ts.erb"
        end

        def unloaded_name
          "Unloaded#{entity_name}"
        end

        def atom_name
          if has_associations?
            "#{entity_name}Atom"
          else
            entity_name
          end
        end

        def all_names
          @all_names ||= if has_associations?
                           [name, unloaded_name, atom_name, aggregate_name]
                         else
                           [name, unloaded_name]
                         end
        end

        def has_associations?
          !associations.empty?
        end

        def aggregate_name
          if has_associations?
            "#{entity_name}Aggregate"
          else
            entity_name
          end
        end
      end
    end
  end
end

=begin
import {AttributesTypeDeclaration, EntityManifest, Manifest} from "../Manifest";
import {BaseGenerator} from "./BaseGenerator";
import {foobaraTypeToTsType} from "./utils/foobara";
import {AssociationDepth} from "./utils/foobara";

export class EntityGenerator extends BaseGenerator<EntityManifest> {

  targetPath(): string[] {
    const pathParts = this.nonGlobalNameParts()

    const entityName = pathParts.pop()

    return [this.targetDir, ...pathParts, "entities", `${entityName}.ts`]
  }

  get entityManifest() {
    return this.relevantManifest
  }

  get entityName() {
    return this.entityManifest.entity_name
  }

  get organizationName() {
    return this.entityManifest.organization_name
  }

  get domainName() {
    return this.entityManifest.domain_name
  }

  get shortName () {
    return this.entityName
  }


  get hasAssociations() {
    return Object.keys(this.entityManifest.associations).length > 0
  }


  entityNameToGenerator(fullName: string) {
    const entityManifest = this.entityNameToManifest(fullName)
    return new EntityGenerator(entityManifest)
  }

  get primaryKeyType() {
    return foobaraTypeToTsType(this.entityManifest.primary_key_type)
  }

  get primaryKeyName () {
    return this.entityManifest.declaration_data.primary_key
  }


  generate() {
    const imports = this.generateEntityImports();


    return `import {Entity, Never, UnloadedAttributesType} from "${this.pathToFoobaraRemote()}/Entity"
${imports}
export type ${this.entityName}PrimaryKeyType = ${this.primaryKeyType}

${this.generateAttributeTypes()}

export class ${this.entityName}<
  AttributesType extends ${this.generateAttributesTypesUnion()} =
      ${this.generateAttributesTypesUnion()}
> extends Entity<${this.entityName}PrimaryKeyType, AttributesType> {
  static readonly entityName: string = "${this.entityName}"
  static readonly primaryKeyAttributeName: "${this.primaryKeyName}" = "${this.primaryKeyName}"


  get ${this.primaryKeyName} (): ${this.entityName}PrimaryKeyType {
    return this.primaryKey
  }

  ${this.generateGetters("AttributesType")}
}

export class UnloadedReferral extends Referral<Never<ReferralAttributesType>> {
  constructor(id: ReferralPrimaryKeyType) {
    super(id)
  }


  get isLoaded(): false { return false }
  get isAtom(): false { return false }
  get isAggregate(): false { return false }
}

export class LoadedReferral<T extends ReferralAttributesType = ReferralAttributesType> extends Referral<T> {
  constructor(id: ReferralPrimaryKeyType, attributes: T) {
    super(id, attributes)
  }

  get isLoaded(): true { return true }

  get channel (): T["channel"] {
    return this._attributes.channel
  }


  get referring_user (): T["referring_user"] {
    return this._attributes.referring_user
  }

  get referred_user (): T["referred_user"] {
    return this._attributes.referred_user
  }
}


export class ReferralAtom extends LoadedReferral<ReferralAttributesType> {
  get isAtom(): true { return true }
}


export class ReferralAggregate extends LoadedReferral<ReferralAggregateAttributesType> {
  get isAggregate(): true { return true }
}

`
  }

  generateGetters(templateVariable: string): string  {
    let result = ""

    for (const attributeName in this.entityManifest.attributes_type.element_type_declarations) {
      if (attributeName === this.primaryKeyName) {
        continue
      }

      result += `
  get ${attributeName} (): ${templateVariable}["${attributeName}"] {
    return this._attributes.${attributeName}
  }
      `
    }

    return result
  }

  get dependsOnNames() {
    return this.entityManifest.depends_on
  }

  generateEntityImports(): string {
    const entityGenerators = this.dependsOnNames.map((entityName) => {
      return this.entityNameToGenerator(entityName)
    })

    const imports = entityGenerators.map((entityGenerator) => {
      const entityName = entityGenerator.entityName

      let types = `import {
        ${entityName},
        Unloaded${entityName},
        ${entityName}AttributesType,
    `

      if (entityGenerator.hasAssociations) {
        types = `${types}
  ${entityName}Atom,
  ${entityName}Aggregate,
  ${entityName}AtomAttributesType,
  ${entityName}AggregateAttributesType,
`
      }

      return `${types}
  ${entityName}PrimaryKeyType
  } from "${this.pathToTargetDir()}${entityGenerator.relativePath()}";`
    })

    return imports.join("\n")
  }


  relativePath(): string {
    return this.nonGlobalNameParts().join("/")
  }


  generateAttributeTypes(): string {
    let result = ""
    // // TODO: perhaps don't have this at all and handle primary key outside of attributes??
    // export interface ReferralAttributesType  {
    //   channel: string
    //   referring_user: User
    //   referred_user: User
    // }
    //
    // export interface ReferralAtomAttributesType extends ReferralAttributesType {
    //   referring_user: UnloadedUser
    //   referred_user: UnloadedUser
    // }
    //
    // export interface ReferralAggregateAttributesType extends ReferralAttributesType {
    //   referring_user: UserAggregate
    //   referred_user: UserAggregate
    // }

    // we should generate non-association types first?

    result += this.generateAttributesType(this.entityManifest.attributes_type, "ambiguous")

    if (this.hasAssociations) {
      result += this.generateAttributesType(this.entityManifest.attributes_type, "atom")
      result += this.generateAttributesType(this.entityManifest.attributes_type, "aggregate")
    }

    return result
  }

  generateAttributesTypesUnion() {
    if (this.hasAssociations) {
      return `${this.entityName}AttributesType | ${this.entityName}AtomAttributesType | ${this.entityName}AggregateAttributesType`
    } else {
      return `${this.entityName}AttributesType`
    }
  }

  generateAttributesType(attributes_type_declaration: AttributesTypeDeclaration, associationDepth: AssociationDepth = "ambiguous"): string {
    let result = ""

    let attributesName: string

    if (associationDepth === "atom") {
      attributesName = `${this.entityName}AtomAttributesType`
    } else if (associationDepth === "aggregate") {
      attributesName = `${this.entityName}AggregateAttributesType`
    } else {
      attributesName = `${this.entityName}AttributesType`
    }

    result += `export interface ${attributesName} {\n`

    for (const attributeName in attributes_type_declaration.element_type_declarations) {
      if (attributeName !== this.primaryKeyName) {
        result += this.generateAttribute(attributes_type_declaration, attributeName, associationDepth)
      }
    }

    result += "}\n\n"

    return result
  }

  generateAttribute(manifest: AttributesTypeDeclaration, attributeName: string, associationDepth: AssociationDepth = "ambiguous"): string {
    const attributeTypeDeclaration = manifest.element_type_declarations[attributeName];
    const isRequired = manifest.required?.includes(attributeName) ? "" : "?";

    const type = foobaraTypeToTsType(attributeTypeDeclaration, this.domainPath, associationDepth);

    return `  ${attributeName}${isRequired}: ${type};\n`;
  }
}



=end
