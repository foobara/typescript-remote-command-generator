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
