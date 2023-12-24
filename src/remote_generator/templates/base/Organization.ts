const globalUrlBase = process.env.REACT_APP_FOOBARA_GLOBAL_URL_BASE

export class Organization {
  static all: {[organizationName: string]: Organization} = {}

  static forName(organizationName: string): Organization {
    if (organizationName in Organization.all) {
      return Organization.all[organizationName]
    } else {
      throw new Error(`Unknown organization name: ${organizationName}`)
    }
  }

  organizationName: string
  isGlobal: boolean
  _urlBase: string | undefined

  constructor(organizationName: string, isGlobal: boolean = false) {
    this.organizationName = organizationName
    this.isGlobal = isGlobal
    Organization.all[organizationName] = this
  }

  get urlBase(): string {
    const base = this._urlBase ?? globalUrlBase

    if (base === undefined) {
      throw new Error("urlBase is not set and REACT_APP_FOOBARA_GLOBAL_URL_BASE is undefined")
    }

    return base
  }

  set urlBase(urlBase: string) {
    this._urlBase = urlBase
  }
}
