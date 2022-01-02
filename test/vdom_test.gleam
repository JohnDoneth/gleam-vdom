import gleam_vdom/vdom.{
  ABool, AText, Element, Text, element, element_, text, to_html,
}
import gleam_vdom/dom
import node_assert.{should_equal}
import gleam/io
import jsdom
import gleam/option.{None, Some}

pub fn node_text_render_test() {
  let html = to_html(text("hello"))

  should_equal(html, "hello")
}

pub fn node_element_render_test() {
  let html = to_html(element("p", [], [text("Hello, world!")]))

  should_equal(html, "<p>Hello, world!</p>")
}

pub fn node_attributes_render_test() {
  let html =
    to_html(element(
      "button",
      [#("disabled", ABool(True)), #("class", AText("my-button"))],
      [Text(value: "Click me!")],
    ))

  should_equal(
    html,
    "<button disabled=\"true\" class=\"my-button\">Click me!</button>",
  )
}
