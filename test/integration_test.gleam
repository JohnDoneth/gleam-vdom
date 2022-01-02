import vdom.{
  ABool, AEventListener, AText, Element, Text, element, element_, text, to_html,
}
import node_assert.{should_equal}
import dom
import gleam/io
import jsdom
import gleam/option.{None, Some}
import diff.{
  ChildDiff, Delete, DeleteKey, Insert, InsertKey, RemoveEventListener, ReplaceText,
  diff,
}
import testing.{child_node_at_index_unchecked, get_global, set_global}

pub fn button_click_event_test() {
  jsdom.init()

  let container = dom.create(element_("div", []))

  let vdom =
    element(
      "button",
      [#("click", AEventListener(fn(_event) { set_global(True) }))],
      [text("Click me!")],
    )

  dom.patch(container, diff(new: Some(vdom), old: None))

  // The event listener should not appear as it's not present in HTML.
  should_equal(
    dom.outer_html(container),
    "<div><button>Click me!</button></div>",
  )

  set_global(False)

  // Click on the button ...
  testing.click(child_node_at_index_unchecked(container, 0))

  // ... which should toggle the global to True.
  should_equal(get_global(), True)
}
