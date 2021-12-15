export function createTextNode(text) {
  if (globalThis.document == undefined) {
    throw "`document` is `undefined`. Did you forget to call `jsdom.init()`?";
  }
  return document.createTextNode(text);
}

export function createElement(tag) {
  if (globalThis.document == undefined) {
    throw "`document` is `undefined`. Did you forget to call `jsdom.init()`?";
  }
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

export function outerHTML(element) {
  return element.outerHTML;
}
