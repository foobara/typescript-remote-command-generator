import { Model } from './Model';
import { valuesAt } from './DataPath';

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
  abstract get associationPropertyPaths (): string[][]

  constructor(primaryKey: PrimaryKeyType, attributes: AttributesType) {
    super(attributes)
    this.primaryKey = primaryKey
    this.isLoaded = attributes !== undefined
  }

  /* Can we make this work or not?
  getConstructor(): EntityConstructor<PrimaryKeyType, AttributesType> {
    return this.constructor as EntityConstructor<PrimaryKeyType, AttributesType>;
  }
  */
  entitiesAt(path: string[]): Entity<EntityPrimaryKeyType, Record<string, any>>[] {
    return valuesAt(this, path).filter(item => item !== undefined) as Entity<EntityPrimaryKeyType, Record<string, any>>[]
  }

  get isAtom(): boolean {
    if (!this.isLoaded) {
      throw new Error("Record is not loaded so can't check if it's an atom")
    }

    if (!this.hasAssociations) {
      return true
    }

    for (const path of this.associationPropertyPaths) {
      for (const record of this.entitiesAt(path)) {
        if (record.isLoaded) {
          return false
        }
      }
    }

    return true
  }

  get isAggregate(): boolean {
    if (!this.isLoaded) {
      throw new Error("Record is not loaded so can't check if it's an aggregate")
    }

    if (!this.hasAssociations) {
      return true
    }

    for (const path of this.associationPropertyPaths) {
      for (const record of this.entitiesAt(path)) {
        if (!record.isLoaded) {
          return false
        }

        if (!record.isAggregate) {
          return false
        }
      }
    }

    return true
  }
  get attributes(): AttributesType {
    if (!this.isLoaded) {
      throw new Error(
        `Cannot read attributes because :${this.primaryKey} is not a loaded record`
      )
    }

    return this._attributes
  }

  override toJSON (): unknown {
    return this.primaryKey
  }
}
