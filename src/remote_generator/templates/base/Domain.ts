export class Domain {
  organizationName: string
  domainName: string
  isGlobal: boolean
  _urlBase: string | undefined

  constructor(organizationName: string, domainName: string, isGlobal: boolean = false) {
    this.organizationName = organizationName
    this.domainName = domainName
    this.isGlobal = isGlobal
  }

  // TODO: make use of domain's config instead of process.env directly.
  get urlBase(): string {
    let base = this._urlBase

    if (!base) {
      base = process.env.REACT_APP_FOOBARA_GLOBAL_URL_BASE
    }

    if (!base) {
      throw new Error("urlBase is not set and REACT_APP_FOOBARA_GLOBAL_URL_BASE is undefined")
    }

    return base
  }

  set urlBase(urlBase: string) {
    this._urlBase = urlBase
  }
}
