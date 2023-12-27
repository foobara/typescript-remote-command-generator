import { Organization } from "./Organization";

export class Domain {
  static domainsByOrganization: {[organizationName: string]: {[domainName: string]: Domain}} = {}

  static forName(organizationName: string, domainName: string): Domain {
    if (organizationName in Domain.domainsByOrganization) {
      if (domainName in Domain.domainsByOrganization[organizationName]) {
        return Domain.domainsByOrganization[organizationName][domainName]
      } else {
        throw new Error(`Unknown domain name: ${domainName}`)
      }
    } else {
      throw new Error(`Unknown organization name: ${organizationName}`)
    }
  }

  organizationName: string
  domainName: string
  isGlobal: boolean
  _urlBase: string | undefined

  constructor(organizationName: string, domainName: string, isGlobal: boolean = false) {
    this.organizationName = organizationName
    this.domainName = domainName
    this.isGlobal = isGlobal

    if (organizationName in Domain.domainsByOrganization) {
      Domain.domainsByOrganization[organizationName][domainName] = this
    } else {
      Domain.domainsByOrganization[organizationName] = {[domainName]: this}
    }
  }

  get urlBase(): string {
    return this._urlBase ?? this.organization.urlBase
  }

  set urlBase(urlBase: string) {
    this._urlBase = urlBase
  }

  get organization(): Organization {
    return Organization.forName(this.organizationName)
  }
}
