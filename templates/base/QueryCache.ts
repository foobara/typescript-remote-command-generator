import type RemoteCommand from '../base/RemoteCommand'
import Query from '../base/Query'
import { type InputsOf, type RemoteCommandConstructor } from '../base/RemoteCommandTypes'

const queryCache = new Map<string, Query<RemoteCommand<any, any, any>>>()

export function getQuery<CommandT extends RemoteCommand<any, any, any>> (
  CommandClass: RemoteCommandConstructor<CommandT>,
  inputs: InputsOf<CommandT> | undefined = undefined
): Query<CommandT> {
  const key: string = toKey(CommandClass, inputs)
  const hit = queryCache.get(key)

  if (hit != null) {
    return (hit as unknown as Query<CommandT>)
  }

  let query: Query<CommandT>

  if (arguments.length === 2) {
    query = new Query<CommandT>(CommandClass, inputs)
    query.run()
  } else {
    query = new Query<CommandT>(CommandClass)
  }

  query.onInputsChange(() => {
    queryCache.delete(key)
    const newKey = toKey(CommandClass, query.inputs)
    queryCache.set(newKey, query)
  })

  queryCache.set(key, query)
  return query
}

export function forEachQuery (callback: (query: Query<RemoteCommand<any, any, any>>) => void): void {
  queryCache.forEach(callback)
}

interface DirtyQueryEvent {
  commandName: string
  propertyName: string | undefined
  value: string | number | undefined
}

let dirtyQueryChannel: BroadcastChannel | null = null

if (typeof BroadcastChannel !== 'undefined') {
  dirtyQueryChannel = new BroadcastChannel('dirty-query')

  dirtyQueryChannel.addEventListener('message', (event: MessageEvent<DirtyQueryEvent>) => {
    const { commandName, propertyName, value } = event.data

    dirtyQuery(commandName, propertyName, value, { skipBroadcast: true })
  })
}

export function dirtyQuery<CommandT extends RemoteCommand<any, any, any>> (
  commandClass: RemoteCommandConstructor<CommandT> | string,
  propertyName: string | undefined = undefined,
  propertyValue: string | number | undefined = undefined,
  options: { skipBroadcast: boolean } = { skipBroadcast: false }) {
  if (typeof commandClass !== 'string') {
    commandClass = commandClass.fullCommandName
  }

  forEachQuery((query) => {
    if (query.CommandClass.fullCommandName === commandClass) {
      if (query.inputs == null || Object.keys(query.inputs).length === 0) {
        query.setDirty()
      } else {
        if (propertyName != null) {
          if (query.inputs[propertyName] !== propertyValue) {
            return
          }
        }

        query.setDirty()
      }
    }
  })

  if (dirtyQueryChannel != null && !options.skipBroadcast) {
    dirtyQueryChannel.postMessage({ commandName: commandClass, propertyName, value: propertyValue })
  }
}

function toKey<CommandT extends RemoteCommand<any, any, any>> (
  CommandClass: RemoteCommandConstructor<CommandT>,
  inputs: InputsOf<CommandT> | undefined
): string {
  let key: string = CommandClass.fullCommandName

  if (inputs != null) {
    key += JSON.stringify(inputs)
  }

  return key
}
