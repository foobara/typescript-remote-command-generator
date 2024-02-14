import { Model } from './Model';

export type Never<T> = {[P in keyof T]: never};

// eslint-disable-next-line @typescript-eslint/no-empty-interface
export type EntityPrimaryKeyType = number | string

export abstract class Entity<PrimaryKeyType extends EntityPrimaryKeyType, AttributesType>
  extends Model<AttributesType> {
  static readonly entityName: string
  static readonly primaryKeyAttributeName: string

  readonly primaryKey: PrimaryKeyType
  readonly isLoaded: boolean

  abstract get hasAssociations(): boolean
  abstract get associationPropertyNames (): (keyof AttributesType)[]

  constructor(primaryKey: PrimaryKeyType, attributes: AttributesType) {
    super(attributes)
    this.primaryKey = primaryKey
    this.isLoaded = attributes !== undefined
  }

  get isAtom(): boolean {
    if (!this.isLoaded) {
      throw new Error("Record is not loaded and so can't check if it's an atom")
    }

    if (!this.hasAssociations) {
      return true
    }

    for (const propertyName of this.associationPropertyNames) {
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

    for (const propertyName of this.associationPropertyNames) {
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

  /* Can we make this work or not?
  getConstructor(): EntityConstructor<PrimaryKeyType, AttributesType> {
    return this.constructor as EntityConstructor<PrimaryKeyType, AttributesType>;
  }
  */

  get attributes(): AttributesType {
    if (!this.isLoaded) {
      throw new Error(
        `Cannot read attributes because :${this.primaryKey} is not a loaded record`
      )
    }

    return this._attributes
  }
}
