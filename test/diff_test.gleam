import vdom.{Element, Text, element, element_, text, to_html}
import node_assert.{should_equal}
import dom
import gleam/io
import jsdom
import gleam/option.{None, Some}
import diff.{ChildDiff, Delete, DeleteKey, Insert, InsertKey, ReplaceText, diff}
import attribute.{AText}

pub fn diff_none_test() {
  should_equal(diff(None, None), [])
}

pub fn diff_insert_test() {
  let diffs = diff(new: Some(text("Hello")), old: None)
  should_equal(diffs, [Insert(index: 0, vdom: text("Hello"))])
}

pub fn diff_delete_test() {
  let diffs = diff(new: None, old: Some(text("Hello")))
  should_equal(diffs, [Delete(index: 0)])
}

pub fn diff_replace_text_test() {
  let diffs = diff(new: Some(text("new_text")), old: Some(text("old_text")))
  should_equal(diffs, [ReplaceText(index: 0, text: "new_text")])
}

pub fn diff_nested_replace_text_test() {
  let diffs =
    diff(
      new: Some(element("div", [], [text("new_text")])),
      old: Some(element("div", [], [text("old_text")])),
    )

  should_equal(
    diffs,
    [
      ChildDiff(
        index: 0,
        attr_diff: [],
        diff: [ReplaceText(index: 0, text: "new_text")],
      ),
    ],
  )
}

pub fn diff_nested_replace_element_and_text_test() {
  let diffs =
    diff(
      new: Some(element(
        "div",
        [],
        [element("p", [], [text("new_text_in_element")])],
      )),
      old: Some(element("div", [], [text("old_text")])),
    )

  should_equal(
    diffs,
    [
      ChildDiff(
        index: 0,
        attr_diff: [],
        diff: [
          Delete(index: 0),
          Insert(
            index: 0,
            vdom: element("p", [], [text("new_text_in_element")]),
          ),
        ],
      ),
    ],
  )
}

pub fn diff_attribute_insert_test() {
  let diffs =
    diff(
      new: Some(element_("p", [#("key", AText("value"))])),
      old: Some(element_("p", [])),
    )
  should_equal(
    diffs,
    [
      ChildDiff(
        index: 0,
        attr_diff: [InsertKey(key: "key", attribute: AText("value"))],
        diff: [],
      ),
    ],
  )
}

pub fn diff_attribute_delete_test() {
  let diffs =
    diff(
      new: Some(element_("p", [])),
      old: Some(element_("p", [#("key", AText("value"))])),
    )
  should_equal(
    diffs,
    [ChildDiff(index: 0, attr_diff: [DeleteKey(key: "key")], diff: [])],
  )
}

pub fn diff_update_existing_attribute_test() {
  let diffs =
    diff(
      new: Some(element_("p", [#("common_key", AText("new_value"))])),
      old: Some(element_("p", [#("common_key", AText("old_value"))])),
    )
  should_equal(
    diffs,
    [
      ChildDiff(
        index: 0,
        attr_diff: [InsertKey(key: "common_key", attribute: AText("new_value"))],
        diff: [],
      ),
    ],
  )
}
