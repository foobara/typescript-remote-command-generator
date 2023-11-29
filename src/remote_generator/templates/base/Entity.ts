export type Never<T> = {[P in keyof T]: never};


export type UnloadedAttributesType = {}
export type EntityPrimaryKeyType = number | string

interface EntityConstructor<PrimaryKeyType extends EntityPrimaryKeyType, AttributesType> {
  new(primaryKey: PrimaryKeyType, attributes: any): Entity<PrimaryKeyType, AttributesType>
  entityName: string
  primaryKeyAttributeName: string
}

export abstract class Entity<PrimaryKeyType extends EntityPrimaryKeyType, AttributesType> {
  static readonly entityName: string
  static readonly primaryKeyAttributeName: string

  readonly primaryKey: PrimaryKeyType
  readonly _isLoaded: boolean
  readonly _attributes: AttributesType

  get hasAssociations() {
    return Object.keys(this.associationsMetadata).length > 0
  }

  abstract get associationsMetadata (): {[key: string]: string}

  constructor(primaryKey: PrimaryKeyType, attributes: AttributesType | undefined = undefined) {
    this.primaryKey = primaryKey

    if (attributes) {
      this._isLoaded = true
      this._attributes = attributes
    } else {
      this._isLoaded = false
      this._attributes = {} as Never<AttributesType>
    }
  }

  get isAtom(): boolean {
    if (!this.isLoaded) {
      throw new Error("Record is not loaded and so can't check if it's an atom")
    }

    if (!this.hasAssociations) {
      return true
    }

    for (const propertyName in this.associationsMetadata) {
      const record = this[propertyName as keyof this] as Entity<EntityPrimaryKeyType, Record<string, any>>

      if (record.isLoaded) {
        return false
      }
    }

    return true
  }

  get isAggregate(): boolean {
    if (!this.isLoaded) {
      throw new Error("Record is not loaded and so can't check if it's an aggregate")
    }

    if (!this.hasAssociations) {
      return true
    }

    for (const propertyName in this.associationsMetadata) {
      const record = this[propertyName as keyof this] as Entity<EntityPrimaryKeyType, Record<string, any>>

      if (!record.isLoaded) {
        return false
      }

      if (!record.isAggregate) {
        return false
      }
    }

    return true
  }

  getConstructor(): EntityConstructor<PrimaryKeyType, AttributesType> {
    return this.constructor as EntityConstructor<PrimaryKeyType, AttributesType>;
  }

  get isLoaded(): boolean {
    return this._isLoaded
  }

  get attributes(): AttributesType {
    if (!this.isLoaded) {
      throw new Error(
        `Cannot read attributes because ${this.getConstructor().entityName}:${this.primaryKey} is not a loaded record`
      )
    }

    return this._attributes
  }

  readAttribute<T extends keyof this["_attributes"]>(attributeName: T): this["_attributes"][T] {
    return (this.attributes as unknown as this["_attributes"])[attributeName]
  }
}