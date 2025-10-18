import type Query from '../../../base/Query'
import type RemoteCommand from '../../../base/RemoteCommand'
import { forEachQuery } from '../../../base/QueryCache'

function dirtyAllQueries () {
  forEachQuery((query: Query<RemoteCommand<any, any, any>>) => {
    query.setDirty()
  })
}

const accessTokens = new Map<string, string>()

const logout = (urlBase: string): void => {
  accessTokens.delete(urlBase)
  dirtyAllQueries()
}
let handleLogout: (baseUrl: string) => void = logout

const tokenForUrl = (baseUrl: string): string | undefined => accessTokens.get(baseUrl)
const handleLogin: (baseUrl: string, accessToken: string) => void = (baseUrl, accessToken) => {
  accessTokens.set(baseUrl, accessToken)
  dirtyAllQueries()
}

if (typeof BroadcastChannel !== 'undefined') {
  const logoutChannel = new BroadcastChannel('foobara-auth-events')

  logoutChannel.addEventListener('message', (event: MessageEvent<string>) => {
    accessTokens.delete(event.data)
  })

  handleLogout = (baseUrl: string) => {
    logout(baseUrl)
    logoutChannel.postMessage(baseUrl)
  }
}

export {
  handleLogin,
  handleLogout,
  tokenForUrl
}
