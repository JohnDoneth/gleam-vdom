import { JSDOM } from "jsdom";

export function init() {
  const jsdom = new JSDOM(`<!DOCTYPE html>`);
  globalThis.document = jsdom.window.document;
}

export function inspectHTML(element) {
  console.log(element.outerHTML);
}
