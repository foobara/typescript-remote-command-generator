import {Domain} from "./Domain";

export class Organization {
  static all: {[organizationName: string]: Organization} = {}
  static forName(organizationName: string): Organization {
    return this.all[organizationName]
  }

  organizationName: string
  isGlobal: boolean
  _urlBase: string | undefined
  domainsByName: {[domainName: string]: Domain} = {}

  constructor(organizationName: string, isGlobal: boolean = false) {
    this.organizationName = organizationName
    this.isGlobal = isGlobal
    Organization.all[organizationName] = this
  }

  domainForName(domainName: string): Domain {
    return this.domainsByName[domainName]
  }

  addDomain(domain: Domain): void {
    this.domainsByName[domain.domainName] = domain
  }

  get urlBase(): string {
    let base = this._urlBase

    if (base == null && this.isGlobal) {
      throw new Error("urlBase not set")
    }

    return base ?? globalOrganization.urlBase
  }

  set urlBase(urlBase: string) {
    this._urlBase = urlBase
  }


}

export const globalOrganization = new Organization("GlobalOrganization", true)

const globalUrlBase = process.env.REACT_APP_FOOBARA_GLOBAL_URL_BASE

if (globalUrlBase != null) {
  globalOrganization.urlBase = globalUrlBase
}
