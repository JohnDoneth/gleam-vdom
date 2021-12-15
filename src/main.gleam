import gleam_vdom.{Element, Text, element, element_, render, text}
import browser
import gleam/option.{None, Some}

// Import a JavaScript function from a global object
external fn log(anything) -> Nil =
  "" "console.log"

external fn init() -> Nil =
  "./ffi.js" "init"

external fn inspect_html(anything) -> Nil =
  "./ffi.js" "inspectHTML"

pub fn main() {
  init()

  let container = browser.create(element_("div", []))

  let desired =
    element(
      "button",
      [#("disabled", "true"), #("class", "my-button")],
      [text("hi")],
    )

  //let x = browser.create(input)
  inspect_html(container)

  browser.update_element(container, Some(desired), None, 0)

  inspect_html(container)

  let desired2 =
    element(
      "button",
      [#("disabled", "true"), #("class", "my-button")],
      [text("lol"), element_("p", [])],
    )

  browser.update_element(container, Some(desired2), Some(desired), 0)

  inspect_html(container)
}
