function flatten (array: any[][]): any[] {
  return array.reduce((acc, val) => acc.concat(val), [])
}

function uniq<T> (array: T[]): T[] {
  return [...new Set(array)]
}

function compact (array: any[]): any[] {
  return array.filter(item => item !== null && item !== undefined)
}

function _valuesAt<T extends (Record<string, any> | any[])> (objects: T[], path: Array<string | number>): any[] {
  if (path.length === 0) return objects

  const [pathPart, ...remainingParts] = path

  let newObjects: any[]

  if (pathPart === '#') {
    const flat = flatten(objects as any[][])
    newObjects = uniq(flat)
  } else if (typeof pathPart === 'number') {
    newObjects = compact(objects.map((object: T) => {
      if (Array.isArray(objects)) {
        return object[pathPart]
      } else {
        throw new Error(`Cannot access index ${pathPart} of object because it's not an array`)
      }
    }))
  } else if (typeof pathPart === 'string') {
    newObjects = compact(objects.map((object: T) => {
      if (typeof object === 'object' && object !== null) {
        return object[pathPart]
      } else {
        throw new Error(`Bad object and part: ${pathPart}`)
      }
    }))
  } else {
    throw new Error(`Bad path part: ${typeof pathPart}`)
  }

  return _valuesAt(newObjects, remainingParts)
}

export function valuesAt<T extends Record<string, any> | any[]> (object: T, path: string[]): any[] {
  return _valuesAt([object], path)
}
