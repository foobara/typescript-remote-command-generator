export interface Outcome<Result, Error> {
  result?: Result;
  errors?: Error[];
  isSuccess: boolean
}

export interface SuccessfulOutcome<Result,Error> extends Outcome<Result,Error> {
  result: Result
  isSuccess: true
}

export interface ErrorOutcome<Result,Error> extends Outcome<Result,Error> {
  errors: Error[]
  isSuccess: false
}
