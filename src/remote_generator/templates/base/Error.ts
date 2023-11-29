export interface Error<keyT extends string, pathT extends string[] = [], runtime_pathT extends string[] = []> {
  key: keyT
  path: pathT
  runtime_path: runtime_pathT
  category: string;
  symbol: string;
  message: string;
  context: any;
}

export interface DataError<keyT extends string, pathT extends string[] = [], runtime_pathT extends string[] = []> extends
  Error<keyT , pathT , runtime_pathT> {
  category: 'data'
}

export interface RuntimeError<keyT extends string, pathT extends string[] = [], runtime_pathT extends string[] = []> extends
  Error<keyT , pathT , runtime_pathT> {
  category: 'runtime'
}

export interface CannotCastError<keyT extends string, pathT extends string[] = [], runtime_pathT extends string[] = []> extends
  DataError<keyT,pathT,runtime_pathT> {
  symbol: 'cannot_cast'
  context: {
    cast_to: any
    value: any
    attribute_name: string
  }
}

export interface MissingRequiredAttributeError<keyT extends string, pathT extends string[] = [], runtime_pathT extends string[] = []> extends
  DataError<keyT,pathT,runtime_pathT> {
  symbol: 'missing_required_attribute'
  context: {
    attribute_name: string
  }
}

export interface UnexpectedAttributesError<keyT extends string, pathT extends string[] = [], runtime_pathT extends string[] = []> extends
  DataError<keyT,pathT,runtime_pathT> {
  symbol: 'unexpected_attributes'
  context: {
    unexpected_attributes: string[]
    allowed_attributes: string[]
  }
}
