export class Organization {
  organizationName: string
  isGlobal: boolean
  _urlBase: string | undefined

  constructor(organizationName: string, isGlobal: boolean = false) {
    this.organizationName = organizationName
    this.isGlobal = isGlobal
  }

  get urlBase(): string {
    let base = this._urlBase

    if (!base && this.isGlobal) {
      throw new Error("urlBase not set")
    }

    return base || globalOrganization.urlBase
  }

  set urlBase(urlBase: string) {
    this._urlBase = urlBase
  }
}

export const globalOrganization = new Organization("global_organization", true)

const globalUrlBase = process.env.REACT_APP_FOOBARA_GLOBAL_URL_BASE

if (globalUrlBase) {
  globalOrganization.urlBase = globalUrlBase
}
