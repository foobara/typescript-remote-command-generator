import RemoteCommand from '../../base/RemoteCommand'
import { type FoobaraError } from '../../base/Error'
import { type Outcome } from '../../base/Outcome'
import { handleLogin } from './utils/accessTokens'

export default class LoginCommand<Inputs, Result, Error extends FoobaraError<any>>
  extends RemoteCommand<Inputs, Result, Error> {
  async _handleResponse (response: Response): Promise<Outcome<Result, Error>> {
    if (response.ok) {
      const accessToken: string | null = response.headers.get('X-Access-Token')

      if (accessToken != null) {
        handleLogin(this.urlBase, accessToken)
      }
    }

    return await super._handleResponse(response)
  }
}
