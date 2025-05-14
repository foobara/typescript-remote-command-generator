import type RemoteCommand from '../base/RemoteCommand'
import { type Outcome } from '../base/Outcome'
import {
  type InputsOf, type ResultOf, type ErrorOf, type RemoteCommandConstructor
} from './RemoteCommandTypes'

export default class Query<CommandT extends RemoteCommand<any, any, any>> {
  inputs: InputsOf<CommandT>
  CommandClass: RemoteCommandConstructor<CommandT>
  command: CommandT | undefined
  isLoading: boolean = false
  isFailure: boolean = false
  isDirty: boolean = false
  ranWhileRunning: boolean = false
  listeners: Array<() => void> = []
  inputsChangedListeners: Array<() => void> = []
  failure: any

  constructor (
    CommandClass: RemoteCommandConstructor<CommandT>,
    inputs: InputsOf<CommandT> | undefined = undefined
  ) {
    this.CommandClass = CommandClass
    this.inputs = inputs ?? (undefined as unknown as InputsOf<CommandT>)
  }

  get outcome (): null | Outcome<ResultOf<CommandT>, ErrorOf<CommandT>> {
    return this.command?.outcome ?? null
  }

  get result (): null | ResultOf<CommandT> {
    return this.command?.outcome?.result ?? null
  }

  get errors (): null | Array<ErrorOf<CommandT>> {
    return this.command?.outcome?.errors ?? null
  }

  onChange (callback: () => void): () => void {
    this.listeners.push(callback)
    return () => {
      const index = this.listeners.indexOf(callback)
      if (index !== -1) {
        this.listeners.splice(index, 1)
      }
    }
  }

  onInputsChange (callback: () => void): () => void {
    this.inputsChangedListeners.push(callback)

    return () => {
      const index = this.inputsChangedListeners.indexOf(callback)
      if (index !== -1) {
        this.inputsChangedListeners.splice(index, 1)
      }
    }
  }

  fireChange (): void {
    this.listeners.forEach(listener => { listener() })
  }

  fireInputsChanged (): void {
    this.inputsChangedListeners.forEach(listener => { listener() })
  }

  setInputs (inputs: InputsOf<CommandT>): void {
    this.inputs = inputs
    this.fireInputsChanged()
    this.setDirty()
  }

  setDirty (): void {
    this.isDirty = true
    this.run()
  }

  get isSuccess (): boolean {
    return !this.isFailure && (this.command?.outcome?.isSuccess() ?? false)
  }

  get isError (): boolean {
    if (this.command?.outcome == null) {
      return false
    }
    return !this.command.outcome.isSuccess()
  }

  get isPending (): boolean {
    return !this.isLoading || !this.isFailure || this.command == null
  }

  async run (): Promise<void> {
    if (this.isLoading) {
      this.ranWhileRunning = true
      this.fireChange()
      return
    }

    try {
      this.isLoading = true
      const command = new this.CommandClass(this.inputs)
      this.fireChange()

      await command.run()

      this.isFailure = false
      this.isDirty = false
      this.command = command
      this.failure = undefined
    } catch (error) {
      this.isFailure = true
      this.failure = error
      throw error
    } finally {
      this.isLoading = false
      this.fireChange()
      if (this.ranWhileRunning) {
        this.ranWhileRunning = false
        this.run()
      }
    }
  }
}
