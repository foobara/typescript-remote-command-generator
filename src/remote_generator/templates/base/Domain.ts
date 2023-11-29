import {globalOrganization, Organization} from "./Organization";

export class Domain {
  organization: Organization
  domainName: string
  isGlobal: boolean
  _urlBase: string | undefined

  constructor(organization: Organization, domainName: string, isGlobal: boolean = false) {
    this.organization = organization
    this.domainName = domainName
    this.isGlobal = isGlobal
  }

  get organizationName(): string {
    return this.organization.organizationName
  }

  get urlBase(): string {
    return this._urlBase || this.organization.urlBase
  }

  set urlBase(urlBase: string) {
    this._urlBase = urlBase
  }
}

export const globalDomain = new Domain(globalOrganization, "global_domain", true)
