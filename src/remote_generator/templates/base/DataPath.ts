function flatten(array: any[]) {
  return array.reduce((acc, val) => acc.concat(val), []);
}

function uniq(array: any[]) {
  return [...new Set(array)];
}

function _valuesAt(objects: Object[], path: (string | number)[]): Object[] {
  if (path.length === 0) return objects

  const [pathPart, ...remainingParts] = path;

  if (pathPart === '#') {
    objects = uniq(flatten(objects))
  } else if (typeof pathPart === 'string' || typeof pathPart === 'number') {
    objects = objects.map((object: Object) => object[pathPart])
  } else {
    throw new Error(`Bad path part: ${pathPart}`)
  }

  return _valuesAt(objects, remainingParts)
}

export function valuesAt(objects: Object[], path: string[]) {
  return _valuesAt([objects], path);
}

