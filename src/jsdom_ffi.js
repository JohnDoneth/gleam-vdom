import { JSDOM } from "jsdom";

export function init() {
  const jsdom = new JSDOM(`<!DOCTYPE html>`);
  globalThis.document = jsdom.window.document;
}
