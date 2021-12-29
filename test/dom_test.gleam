import vdom.{Element, Text, element, element_, text, to_html}
import node_assert.{should_equal}
import dom
import gleam/io
import jsdom
import gleam/option.{None, Some}
import diff.{ChildDiff, Delete, DeleteKey, Insert, InsertKey, ReplaceText}
import attribute.{ABool, AText}

pub fn apply_diff_insert_test() {
  jsdom.init()

  let container = dom.create(element_("div", []))

  dom.apply_diff(container, Insert(index: 0, vdom: text("test")))

  should_equal(dom.outer_html(container), "<div>test</div>")
}

pub fn apply_diff_insert_1st_test() {
  jsdom.init()

  let container =
    dom.create(element("ul", [], [element("li", [], [text("2")])]))

  should_equal(dom.outer_html(container), "<ul><li>2</li></ul>")

  dom.apply_diff(
    container,
    Insert(index: 0, vdom: element("li", [], [text("1")])),
  )

  should_equal(dom.outer_html(container), "<ul><li>1</li><li>2</li></ul>")
}

pub fn apply_diff_delete_test() {
  jsdom.init()

  let container = dom.create(element("div", [], [text("test")]))

  should_equal(dom.outer_html(container), "<div>test</div>")

  dom.apply_diff(container, Delete(index: 0))

  should_equal(dom.outer_html(container), "<div></div>")
}

pub fn apply_diff_delete_1st_item_test() {
  jsdom.init()

  let container =
    dom.create(element(
      "ul",
      [],
      [element("li", [], [text("1")]), element("li", [], [text("2")])],
    ))

  should_equal(dom.outer_html(container), "<ul><li>1</li><li>2</li></ul>")

  dom.apply_diff(container, Delete(index: 0))

  should_equal(dom.outer_html(container), "<ul><li>2</li></ul>")
}

pub fn apply_diff_delete_2nd_item_test() {
  jsdom.init()

  let container =
    dom.create(element(
      "ul",
      [],
      [element("li", [], [text("1")]), element("li", [], [text("2")])],
    ))

  should_equal(dom.outer_html(container), "<ul><li>1</li><li>2</li></ul>")

  dom.apply_diff(container, Delete(index: 1))

  should_equal(dom.outer_html(container), "<ul><li>1</li></ul>")
}

pub fn apply_diff_update_text_test() {
  jsdom.init()

  let container = dom.create(element("div", [], [text("update me!")]))

  should_equal(dom.outer_html(container), "<div>update me!</div>")

  dom.apply_diff(container, ReplaceText(index: 0, text: "I'm updated!"))

  should_equal(dom.outer_html(container), "<div>I'm updated!</div>")
}

pub fn apply_diff_child_diff_test() {
  jsdom.init()

  let container =
    dom.create(element(
      "div",
      [],
      [element("div", [], [element("div", [], [text("update me!")])])],
    ))

  should_equal(
    dom.outer_html(container),
    "<div><div><div>update me!</div></div></div>",
  )

  dom.apply_diff(
    container,
    ChildDiff(
      index: 0,
      attr_diff: [],
      diff: [
        ChildDiff(
          index: 0,
          attr_diff: [],
          diff: [ReplaceText(index: 0, text: "I'm updated!")],
        ),
      ],
    ),
  )

  should_equal(
    dom.outer_html(container),
    "<div><div><div>I'm updated!</div></div></div>",
  )
}

pub fn apply_diff_insert_attribute_test() {
  jsdom.init()

  let container = dom.create(element("div", [], [element("button", [], [])]))

  dom.apply_diff(
    container,
    ChildDiff(
      index: 0,
      attr_diff: [InsertKey(key: "disabled", attribute: ABool(True))],
      diff: [],
    ),
  )

  should_equal(
    dom.outer_html(container),
    "<div><button disabled=\"true\"></button></div>",
  )
}

pub fn apply_diff_delete_attribute_test() {
  jsdom.init()

  let container =
    dom.create(element(
      "div",
      [],
      [element("button", [#("disabled", ABool(True))], [])],
    ))

  should_equal(
    dom.outer_html(container),
    "<div><button disabled=\"true\"></button></div>",
  )

  dom.apply_diff(
    container,
    ChildDiff(index: 0, attr_diff: [DeleteKey(key: "disabled")], diff: []),
  )

  should_equal(dom.outer_html(container), "<div><button></button></div>")
}
