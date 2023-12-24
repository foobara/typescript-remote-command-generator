export interface ErrorT {
  key: string
  symbol: string
  category: "data" | "runtime"
  context: any
  path: string[]
  runtime_path: string[]
  message: string
}

export interface DataError extends ErrorT {
  category: "data"
}

export interface RuntimeError extends ErrorT {
  category: "runtime"
}
