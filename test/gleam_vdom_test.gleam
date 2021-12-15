import vnode.{Element, Text, element, element_, render, text}
import node_assert.{should_equal}
import browser
import gleam/io
import jsdom
import gleam/option.{None, Some}

pub fn node_text_render_test() {
  let rendered = render(text("hello"))

  should_equal(rendered, "hello")
}

pub fn node_element_render_test() {
  let rendered = render(element("p", [], [text("Hello, world!")]))

  should_equal(rendered, "<p>Hello, world!</p>")
}

pub fn node_attributes_render_test() {
  let rendered =
    render(element(
      "button",
      [#("disabled", "true"), #("class", "my-button")],
      [Text(value: "Click me!")],
    ))

  should_equal(
    rendered,
    "<button disabled=\"true\" class=\"my-button\">Click me!</button>",
  )
}

pub fn update_element_test() {
  jsdom.init()

  let container = browser.create(element_("div", []))

  should_equal(browser.outer_html(container), "<div></div>")

  let desired = element("button", [], [text("hi")])

  browser.update_element(container, Some(desired), None, 0)

  should_equal(browser.outer_html(container), "<div><button>hi</button></div>")
}

pub fn update_existing_element_test() {
  jsdom.init()

  let container = browser.create(element_("div", []))

  let initial = element("button", [], [text("Click me!")])
  let desired = element("button", [], [text("Nevermind"), element_("p", [])])

  // Update without existing state.
  browser.update_element(container, new: Some(desired), old: None, index: 0)

  // Update with existing state.
  browser.update_element(
    container,
    new: Some(desired),
    old: Some(initial),
    index: 0,
  )

  should_equal(
    browser.outer_html(container),
    "<div><button>Nevermind<p></p></button></div>",
  )
}
