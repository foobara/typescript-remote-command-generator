export abstract class Model<AttributesType> {
  static readonly modelName: string
  readonly _attributes: AttributesType


  constructor(attributes: AttributesType) {
    this._attributes = attributes
  }


  /* Can we make this work or not?
  getConstructor(): EntityConstructor<PrimaryKeyType, AttributesType> {
    return this.constructor as EntityConstructor<PrimaryKeyType, AttributesType>;
  }
  */

  get attributes(): AttributesType {
    return this._attributes
  }

  readAttribute<T extends keyof this["_attributes"]>(attributeName: T): this["_attributes"][T] {
    return (this.attributes as unknown as this["_attributes"])[attributeName]
  }
}
