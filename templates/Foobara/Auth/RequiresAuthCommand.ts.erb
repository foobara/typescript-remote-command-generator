import RemoteCommand from '../../base/RemoteCommand'
import { type Outcome } from '../../base/Outcome'
import { type FoobaraError } from '../../base/Error'
import { tokenForUrl } from './utils/accessTokens'

export default class RequiresAuthCommand<Inputs, Result, Error extends FoobaraError<any>>
  extends RemoteCommand<Inputs, Result, Error> {
  _buildRequestParams (): RequestInit {
    const requestParams = super._buildRequestParams()

    const bearerToken = tokenForUrl(this.urlBase)

    if (bearerToken != null && requestParams.headers != null) {
      requestParams.headers = { ...requestParams.headers, Authorization: `Bearer ${bearerToken}` }
    }

    return requestParams
  }

  async _handleResponse (response: Response): Promise<Outcome<Result, Error>> {
    response = await this._handleUnauthenticated(response)

    return await super._handleResponse(response)
  }

  async _handleUnauthenticated (response: Response): Promise<Response> {
    if (response.status === 401) {
      this.commandState = 'refreshing_authentication'

      const { RefreshLogin } = await import('./RefreshLogin')
      // See if we can authenticate using the refresh token
      const refreshCommand = new RefreshLogin()
      const outcome = await refreshCommand.run()

      if (outcome.isSuccess()) {
        this.commandState = 'executing'
        response = await this._issueRequest()
      }
    }

    return response
  }
}
