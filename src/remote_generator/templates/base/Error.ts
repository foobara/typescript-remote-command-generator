/* eslint-disable @typescript-eslint/naming-convention */

export abstract class FoobaraError<contextT = any> {
  static readonly symbol: string
  static readonly category: 'data' | 'runtime'

  readonly key: string
  readonly path: string[]
  readonly runtime_path: string[]
  readonly message: string
  readonly context: contextT

  constructor ({ key, path, runtime_path, message, context }:
                 { key: string, path?: string[], runtime_path?: string[], message: string, context: contextT }) {
    this.key = key
    this.path = path ?? []
    this.runtime_path = runtime_path ?? []
    this.message = message
    this.context = context
  }
}

export class DataError<contextT extends Record<string, any>> extends FoobaraError<contextT> {
  static readonly category: 'data' = 'data'
}

export class RuntimeError<contextT extends Record<string, any>> extends FoobaraError<contextT> {
  static readonly category: 'runtime' = 'runtime'
}
