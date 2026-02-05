import type Query from '../../../base/Query'
import type RemoteCommand from '../../../base/RemoteCommand'
import { forEachQuery } from '../../../base/QueryCache'

// TODO: Why is this in here? It seems general-purpose not auth-specific
function dirtyAllQueries () {
  forEachQuery((query: Query<RemoteCommand<any, any, any>>) => {
    query.setDirty()
  })
}

const accessTokens = new Map<string, string>()

interface AuthMessage {
  type: 'login' | 'logout'
  baseUrl: string
}

const login = (baseUrl: string, accessToken: string): void => {
  accessTokens.set(baseUrl, accessToken)
  dirtyAllQueries()
}

const logout = (urlBase: string): void => {
  accessTokens.delete(urlBase)
  dirtyAllQueries()
}

// These functions gets overridden with a form that broadcasts the event if BroadcastChannel is available
let handleLogin: (baseUrl: string, accessToken: string) => void = login
let handleLogout: (baseUrl: string) => void = logout

const tokenForUrl = (baseUrl: string): string | undefined => accessTokens.get(baseUrl)

if (typeof BroadcastChannel !== 'undefined') {
  const logoutChannel = new BroadcastChannel('foobara-auth-events')

  logoutChannel.addEventListener('message', (event: MessageEvent<AuthMessage>) => {
    const { type, baseUrl } = event.data

    if (type === 'login') {
      dirtyAllQueries()
    } else if (type === 'logout') {
      logout(baseUrl)
    } else {
      throw new Error(`Unknown auth message type: ${JSON.stringify(type)}`)
    }
  })

  handleLogout = (baseUrl: string) => {
    logout(baseUrl)
    logoutChannel.postMessage({ baseUrl, type: 'logout' })
  }
  handleLogin = (baseUrl: string, accessToken: string) => {
    login(baseUrl, accessToken)
    logoutChannel.postMessage({ baseUrl, type: 'login' })
  }
}

export {
  handleLogin,
  handleLogout,
  tokenForUrl
}
