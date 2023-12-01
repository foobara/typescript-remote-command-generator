interface ErrorT {
  key: string
  symbol: string
  category: "data" | "runtime"
  context: any
  path: []
  runtime_path: []
}

interface DataError extends Error {
  category: "data"
}

interface RuntimeError extends Error {
  category: "runtime"
}
