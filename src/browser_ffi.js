export function createTextNode(text) {
  return document.createTextNode(text);
}

export function createElement(tag) {
  return document.createElement(tag);
}

export function appendChild(element, child) {
  return element.appendChild(child);
}

export function childNodeAtIndexUnchecked(element, index) {
  return element.childNodes[index];
}

export function removeChild(element, child) {
  element.removeChild(child);
}

export function replaceChild(parent, child, replacement) {
  parent.replaceChild(child, replacement);
}
