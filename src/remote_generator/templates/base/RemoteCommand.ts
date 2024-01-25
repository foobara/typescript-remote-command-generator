import { type Outcome, SuccessfulOutcome, ErrorOutcome } from './Outcome'
import { type FoobaraError } from './Error'

export default abstract class RemoteCommand<Inputs, Result, CommandError extends FoobaraError> {
  static _urlBase: string | undefined
  static commandName: string
  static organizationName: string
  static domainName: string

  // TODO: make use of domain's config instead of process.env directly.
  static get urlBase (): string {
    let base = this._urlBase

    if (base == null) {
      base = process.env.REACT_APP_FOOBARA_GLOBAL_URL_BASE
    }

    if (base == null) {
      throw new Error("urlBase is not set and REACT_APP_FOOBARA_GLOBAL_URL_BASE is undefined")
    }

    return base
  }

  static set urlBase (urlBase: string) {
    this._urlBase = urlBase
  }

  get organizationName (): string {
    return (this.constructor as typeof RemoteCommand<Inputs, Result, CommandError>).organizationName
  }

  get domainName (): string {
    return (this.constructor as typeof RemoteCommand<Inputs, Result, CommandError>).domainName
  }

  inputs: Inputs

  constructor (inputs: Inputs) {
    this.inputs = inputs
  }

  get commandName (): string {
    return (this.constructor as typeof RemoteCommand<Inputs, Result, CommandError>).commandName
  }

  get urlBase (): string {
    return (this.constructor as typeof RemoteCommand<Inputs, Result, CommandError>).urlBase
  }

  static get fullCommandName (): string {
    return [this.organizationName, this.domainName, this.commandName].filter(Boolean).join('::')
  }

  get fullCommandName (): string {
    return (this.constructor as typeof RemoteCommand<Inputs, Result, CommandError>).fullCommandName
  }

  async run (): Promise<Outcome<Result, CommandError>> {
    const url = `${this.urlBase}/run/${this.fullCommandName}`

    const response = await fetch(url, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(this.inputs)
    })

    if (response.ok) {
      return new SuccessfulOutcome<Result, CommandError>(await response.json())
    } else if (response.status === 422) {
      return new ErrorOutcome<Result, CommandError>(await response.json())
    } else {
      throw new Error(`not sure how to handle ${await response.text()}`)
    }
  }
}
