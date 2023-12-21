import {Domain} from "./Domain";

export abstract class Organization {
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

  abstract domainForName(domainName: string): Domain

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
