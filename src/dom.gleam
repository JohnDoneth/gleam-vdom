//// Module for interfacing with the non-virtual DOM.

import vdom.{Element, Text, VDOM}
import gleam/list
import gleam/option.{None, Option, Some}
import gleam/io
import gleam/int
import gleam/iterator
import diff.{ChildDiff, Delete, Diff, Insert, ReplaceText}

/// Represents a DOM [Element](https://developer.mozilla.org/en-US/docs/Web/API/Element).
pub external type DOMElement

external fn create_text_node(String) -> DOMElement =
  "./dom_ffi.js" "createTextNode"

external fn create_element(String) -> DOMElement =
  "./dom_ffi.js" "createElement"

external fn append_child(DOMElement, DOMElement) -> Nil =
  "./dom_ffi.js" "appendChild"

external fn child_node_at_index_unchecked(DOMElement, Int) -> DOMElement =
  "./dom_ffi.js" "childNodeAtIndexUnchecked"

external fn remove_child(DOMElement, DOMElement) -> Nil =
  "./dom_ffi.js" "removeChild"

external fn replace_child(DOMElement, DOMElement, DOMElement) -> Nil =
  "./dom_ffi.js" "replaceChild"

external fn insert_before(DOMElement, DOMElement, DOMElement) -> Nil =
  "./dom_ffi.js" "insertBefore"

external fn children_length(DOMElement) -> Int =
  "./dom_ffi.js" "childrenLength"

external fn set_text_content(DOMElement, String) -> Nil =
  "./dom_ffi.js" "setTextContent"

/// Returns the value of [outerHTML](https://developer.mozilla.org/en-US/docs/Web/API/Element/outerHTML)
/// for the provided `DOMElement`
pub external fn outer_html(DOMElement) -> String =
  "./dom_ffi.js" "outerHTML"

/// Creates a real DOM element from a virtual node; Including all of it's children.
pub fn create(node: VDOM) -> DOMElement {
  case node {
    Element(tag: tag, children: children, ..) -> {
      let element = create_element(tag)
      children
      |> list.map(create)
      |> list.map(fn(child) { append_child(element, child) })
      element
    }
    Text(value: value) -> create_text_node(value)
  }
}

/// Applies multiple `diff`s under a given element.
pub fn patch(parent: DOMElement, diff_list: List(Diff)) -> DOMElement {
  list.map(diff_list, fn(diff) { apply_diff(parent, diff) })
  parent
}

/// Applies a single  `diff` under a given element.
pub fn apply_diff(node: DOMElement, diff: Diff) -> DOMElement {
  case diff {
    Delete(index: index) -> {
      let child = child_node_at_index_unchecked(node, index)
      remove_child(node, child)
      node
    }
    Insert(index: index, vdom: vdom) -> {
      let child = create(vdom)
      case index >= children_length(node) {
        True -> append_child(node, child)
        False ->
          insert_before(node, child, child_node_at_index_unchecked(node, index))
      }
      node
    }
    ReplaceText(index: index, text: text) -> {
      let child = child_node_at_index_unchecked(node, index)
      set_text_content(child, text)
      node
    }
    ChildDiff(index: index, attr_diff: _attr_diff_list, diff: diff_list) -> {
      let child = child_node_at_index_unchecked(node, index)
      list.map(diff_list, fn(diff) { apply_diff(child, diff) })
      node
    }
  }
}
