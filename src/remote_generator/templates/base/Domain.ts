import { Organization} from "./Organization";

export class Domain {
  organizationName: string
  domainName: string
  isGlobal: boolean
  _urlBase: string | undefined

  constructor(organizationName: string, domainName: string, isGlobal: boolean = false) {
    this.organizationName = organizationName
    this.domainName = domainName
    this.isGlobal = isGlobal

    this.organization.addDomain(this)
  }

  get urlBase(): string {
    return this._urlBase || this.organization.urlBase
  }

  set urlBase(urlBase: string) {
    this._urlBase = urlBase
  }

  get organization(): Organization {
    return Organization.forName(this.organizationName)
  }
}

export const globalDomain = new Domain("GlobalOrganization", "GlobalDomain", true)
