import { type Outcome, SuccessfulOutcome, ErrorOutcome } from './Outcome'
import { Organization } from './Organization'
import { Domain } from './Domain'

export default abstract class RemoteCommand<Inputs, Result, Error> {
  static _urlBase: string | undefined
  static commandName: string
  static organizationName: string
  static domainName: string

  static get urlBase (): string {
    return this._urlBase ?? this.domain.urlBase
  }

  static set urlBase (urlBase: string) {
    this._urlBase = urlBase
  }

  static get organization (): Organization {
    return Organization.forName(this.organizationName)
  }

  static get domain (): Domain {
    return Domain.forName(this.organizationName, this.domainName)
  }

  get organization (): Organization {
    return (this.constructor as typeof RemoteCommand<Inputs, Result, Error>).organization
  }

  get domain (): Domain {
    return (this.constructor as typeof RemoteCommand<Inputs, Result, Error>).domain
  }

  get organizationName (): string {
    return this.organization.organizationName
  }

  get domainName (): string {
    return this.domain.domainName
  }

  inputs: Inputs

  constructor (inputs: Inputs) {
    this.inputs = inputs
  }

  get commandName (): string {
    return (this.constructor as typeof RemoteCommand<Inputs, Result, Error>).commandName
  }

  get urlBase (): string {
    return (this.constructor as typeof RemoteCommand<Inputs, Result, Error>).urlBase
  }

  static get fullCommandName (): string {
    return [this.organizationName, this.domainName, this.commandName].filter(Boolean).join('::')
  }

  get fullCommandName (): string {
    return (this.constructor as typeof RemoteCommand<Inputs, Result, Error>).fullCommandName
  }

  async run (): Promise<Outcome<Result, Error>> {
    const url = `${this.urlBase}/run/${this.fullCommandName}`

    const response = await fetch(url, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(this.inputs)
    })

    if (response.ok) {
      return new SuccessfulOutcome<Result, Error>(await response.json())
    } else if (response.status === 422) {
      return new ErrorOutcome<Result, Error>(await response.json())
    } else {
      throw new Error(`not sure how to handle ${await response.text()}`)
    }
  }
}
