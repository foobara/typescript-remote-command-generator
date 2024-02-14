function _valuesAt(objects: Object[], path: string[]) {
  if (path.length === 0) return objects;

  const [pathPart, ...remainingParts] = path;

  if (pathPart === '#') {
    objects = [...new Set(objects.flat())];
  } else if (typeof pathPart === 'string' || typeof pathPart === 'number') {
    objects = objects.map((object: Object) => object[pathPart]);
  } else {
    throw new Error(`Bad path part: ${pathPart}`);
  }

  return _valuesAt(objects, remainingParts);
}

export function valuesAt(objects: Object[], path: string[]) {
  return _valuesAt([objects], path);
}

