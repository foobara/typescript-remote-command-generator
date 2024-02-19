import { type FoobaraError } from './Error'

export class Outcome<Result, OutcomeError extends FoobaraError> {
  readonly result?: Result
  readonly errors: OutcomeError[] = []
  readonly _isSuccess: boolean

  constructor (result?: Result, errors?: OutcomeError[]) {
    this.result = result
    if (errors != null) {
      this.errors = errors
    }
    this._isSuccess = errors == null || errors.length === 0
  }

  isSuccess (): this is SuccessfulOutcome<Result, OutcomeError> {
    return this._isSuccess
  }

  get errorMessage (): string {
    return this.errors.map(e => e.message).join(', ')
  }
}

export class SuccessfulOutcome<Result, OutcomeError extends FoobaraError> extends Outcome<Result, OutcomeError> {
  readonly _isSuccess: true = true
  readonly errors: OutcomeError[] = []
  readonly result: Result

  constructor (result: Result) {
    super(result, [])
    this.result = result
  }
}

export class ErrorOutcome<Result, OutcomeError extends FoobaraError> extends Outcome<Result, OutcomeError> {
  readonly _isSuccess: false = false

  constructor (errors: OutcomeError[]) {
    super(undefined, errors)
  }
}
