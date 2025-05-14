import type RemoteCommand from '../base/RemoteCommand'
import { type Outcome } from '../base/Outcome'
import {
  type InputsOf, type ResultOf, type ErrorOf, type RemoteCommandConstructor
} from '../base/RemoteCommandTypes'
import type Query from '../base/Query'
import { useState, useRef, useEffect } from 'react'
import { getQuery } from '../base/QueryCache'

interface QueryState<CommandT extends RemoteCommand<any, any, any>> {
  isLoading: boolean
  isPending: boolean
  isFailure: boolean
  isSuccess: boolean
  isError: boolean
  outcome: null | Outcome<ResultOf<CommandT>, ErrorOf<CommandT>>
  result: null | ResultOf<CommandT>
  errors: null | Array<ErrorOf<CommandT>>
  failure: any
  setInputs: (inputs: InputsOf<CommandT>) => void
  setDirty: () => void
}

function queryToQueryState<CommandT extends RemoteCommand<any, any, any>> (
  query: Query<CommandT>
): QueryState<CommandT> {
  return {
    isLoading: query.isLoading,
    isPending: query.isPending,
    isFailure: query.isFailure,
    isSuccess: query.isSuccess,
    isError: query.isError,
    outcome: query.outcome,
    result: query.result,
    errors: query.errors,
    failure: query.failure,
    setInputs: (inputs: InputsOf<CommandT>) => { query.setInputs(inputs) },
    setDirty: () => { query.setDirty() }
  }
}

export default function useQuery<CommandT extends RemoteCommand<any, any, any>> (
  CommandClass: RemoteCommandConstructor<CommandT>,
  inputs: InputsOf<CommandT> | undefined = undefined
): QueryState<CommandT> {
  const queryRef = useRef<Query<CommandT>>(null)

  let query = queryRef.current

  if (query == null) {
    if (arguments.length === 2) {
      query = getQuery(CommandClass, inputs as InputsOf<CommandT>)
    } else {
      query = getQuery(CommandClass)
    }

    queryRef.current = query
  }

  useEffect(() => {
    const unsubscribe = query?.onChange(() => {
      if (query != null) { // just here to satisfy type checker
        setQueryState(queryToQueryState<CommandT>(query))
      }
    })

    return unsubscribe
  }, [query])

  const [queryState, setQueryState] = useState<QueryState<CommandT>>(
    queryToQueryState<CommandT>(query)
  )

  return queryState
}
