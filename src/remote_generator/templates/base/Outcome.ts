export class Outcome<Result, Error> {
  readonly result?: Result
  readonly errors: Error[] = []
  readonly _isSuccess: boolean

  constructor (result?: Result, errors?: Error[]) {
    this.result = result
    if (errors != null) {
      this.errors = errors
    }
    this._isSuccess = errors == null || errors.length === 0
  }

  isSuccess (): this is SuccessfulOutcome<Result, Error> {
    return this._isSuccess
  }
}

export class SuccessfulOutcome<Result, Error> extends Outcome<Result, Error> {
  readonly _isSuccess: true = true
  readonly errors: Error[] = []
  readonly result: Result

  constructor (result: Result) {
    super(result, [])
    this.result = result
  }
}

export class ErrorOutcome<Result, Error> extends Outcome<Result, Error> {
  readonly _isSuccess: false = false

  constructor (errors: Error[]) {
    super(undefined, errors)
  }
}
