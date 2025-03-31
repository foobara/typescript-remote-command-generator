import RemoteCommand from '../../base/RemoteCommand'
import { type FoobaraError } from '../../base/Error'
import { type Outcome } from '../../base/Outcome'
import { handleLogout } from './utils/accessTokens'

export default class LogoutCommand<Inputs, Result, Error extends FoobaraError<any>>
  extends RemoteCommand<Inputs, Result, Error> {
  async run (): Promise<Outcome<Result, Error>> {
    const outcome = await super.run()

    if (outcome.isSuccess()) {
      // Broadcast logout event to all tabs
      handleLogout(this.urlBase)
    }

    return outcome
  }
}
