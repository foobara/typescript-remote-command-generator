import { type Outcome, SuccessfulOutcome, ErrorOutcome } from './Outcome'
import { type FoobaraError } from './Error'

export type commandState = 'initialized' | 'executing' | 'refreshing_auth' | 'succeeded' | 'errored' | 'failed'

const accessTokens: Record<string, string> = {}

export default abstract class RemoteCommand<Inputs, Result, CommandError extends FoobaraError> {
  static _urlBase: string | undefined
  static commandName: string
  static organizationName: string
  static domainName: string
  static authRequired: boolean = true // TODO: set this from generator

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

  inputs: Inputs
  outcome: null | Outcome<Result, CommandError>
  commandState: commandState

  constructor (inputs: Inputs) {
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
    return this.fullCommandName.replace('::', '/')
  }

  async run (): Promise<Outcome<Result, CommandError>> {
    const url = `${this.urlBase}/run/${this.commandPath}`

    const bearerToken = accessTokens[this.urlBase]

    const requestParams: RequestInit = {
      method: 'POST',
      body: JSON.stringify(this.inputs),
      credentials: 'include'
    }

    requestParams.headers = { 'Content-Type': 'application/json' }

    if (bearerToken != null) {
      requestParams.headers.Authorization = `Bearer ${bearerToken}`
    }

    this.commandState = 'executing'
    let response = await fetch(url, requestParams)

    if ((this.constructor as typeof RemoteCommand<Inputs, Result, CommandError>).authRequired &&
        response.status === 401) {
      this.commandState = 'refreshing_auth'

      // TODO: in generator make this conditional
      const { RefreshLogin } = await import('../Foobara/Auth')
      // See if we can authenticate using the refresh token
      const refreshCommand = new RefreshLogin({})
      const outcome = await refreshCommand.run()

      if (outcome.isSuccess()) {
        const bearerToken = accessTokens[this.urlBase]

        if (bearerToken != null) {
          requestParams.headers.Authorization = `Bearer ${bearerToken}`
        }

        this.commandState = 'executing'
        response = await fetch(url, requestParams)
      }
    }

    const body = await response.json()

    if (response.ok) {
      const accessToken: string | null = response.headers.get('X-Access-Token')

      if (accessToken != null) {
        accessTokens[this.urlBase] = accessToken
      }

      this.commandState = 'succeeded'
      this.outcome = new SuccessfulOutcome<Result, CommandError>(body)
    } else if (response.status === 422) {
      this.commandState = 'errored'
      this.outcome = new ErrorOutcome<Result, CommandError>(body)
    } else {
      this.commandState = 'failed'
      throw new Error(`not sure how to handle ${await response.text()}`)
    }

    return this.outcome
  }
}
