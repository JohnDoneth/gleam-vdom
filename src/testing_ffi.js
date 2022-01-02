let global = true;

export function setGlobal(value) {
  global = value;
}

export function getGlobal() {
  return global;
}

export function click(element) {
  element.click();
}
