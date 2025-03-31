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
      throw new Error('urlBase is not set and REACT_APP_FOOBARA_GLOBAL_URL_BASE is undefined')
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

  inputs: Inputs | undefined
  outcome: null | Outcome<Result, CommandError>
  commandState: string

  constructor (inputs: Inputs | undefined = undefined) {
    this.inputs = inputs
    this.commandState = 'initialized'
    this.outcome = null
  }

  get commandName (): string {
    return (this.constructor as typeof RemoteCommand<Inputs, Result, CommandError>).commandName
  }

  get urlBase (): string {
    return (this.constructor as typeof RemoteCommand<Inputs, Result, CommandError>).urlBase
  }

  static get fullCommandName (): string {
    const path = []

    if (this.organizationName != null && this.organizationName !== 'GlobalOrganization') {
      path.push(this.organizationName)
    }
    if (this.domainName != null && this.domainName !== 'GlobalDomain') {
      path.push(this.domainName)
    }
    if (this.commandName != null) {
      path.push(this.commandName)
    }
    return path.join('::')
  }

  get fullCommandName (): string {
    return (this.constructor as typeof RemoteCommand<Inputs, Result, CommandError>).fullCommandName
  }

  get commandPath (): string {
    return this.fullCommandName.replaceAll('::', '/')
  }

  async run (): Promise<Outcome<Result, CommandError>> {
    this.commandState = 'executing'
    const response = await this._issueRequest()

    this.outcome = await this._handleResponse(response)

    return this.outcome
  }

  _buildUrl (): string {
    return `${this.urlBase}/run/${this.commandPath}`
  }

  _buildRequestParams (): RequestInit {
    return {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(this.inputs),
      credentials: 'include'
    }
  }

  async _issueRequest (): Promise<Response> {
    return await fetch(this._buildUrl(), this._buildRequestParams())
  }

  async _handleResponse (response: Response): Promise<Outcome<Result, CommandError>> {
    const text = await response.text()
    const body = JSON.parse(text)

    if (response.ok) {
      this.commandState = 'succeeded'
      this.outcome = new SuccessfulOutcome<Result, CommandError>(body)
    } else if (response.status === 422 || response.status === 401 || response.status === 403) {
      this.commandState = 'errored'
      this.outcome = new ErrorOutcome<Result, CommandError>(body)
    } else {
      this.commandState = 'failed'
      throw new Error(`not sure how to handle ${text}`)
    }

    return this.outcome
  }
}
