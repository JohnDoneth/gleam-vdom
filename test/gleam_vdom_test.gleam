import gleam_vdom.{Element, Text, element, element_, render, text}
import gleam/map
import gleeunit
import gleeunit/should

pub fn main() {
  gleeunit.main()
}

pub fn node_text_render_test() {
  let rendered = render(text("hello"))

  should.equal(rendered, "hello")
}

pub fn node_element_render_test() {
  let rendered = render(element("p", [], [text("Hello, world!")]))

  should.equal(rendered, "<p>Hello, world!</p>")
}

pub fn node_attributes_render_test() {
  let rendered =
    render(element(
      "button",
      [#("disabled", "true"), #("class", "my-button")],
      [Text(value: "Click me!")],
    ))

  should.equal(
    rendered,
    "<button class=\"my-button\" disabled=\"true\">Click me!</button>",
  )
}
