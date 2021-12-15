//// Module for interfacing with the non-virtual DOM.

import vnode.{Element, Text, VNode}
import gleam/list
import gleam/option.{None, Option, Some}
import gleam/io
import gleam/int
import gleam/iterator

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

/// Returns the value of [outerHTML](https://developer.mozilla.org/en-US/docs/Web/API/Element/outerHTML)
/// for the provided `DOMElement`
pub external fn outer_html(DOMElement) -> String =
  "./dom_ffi.js" "outerHTML"

/// Creates a real DOM element from a virtual node; Including all of it's children.
pub fn create(node: VNode) -> DOMElement {
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

fn changed(node1: VNode, node2: VNode) -> Bool {
  case node1, node2 {
    Text(_), Element(..) -> True
    Element(..), Text(_) -> True
    Text(a), Text(b) -> a != b
    Element(tag: node1tag, ..), Element(tag: node2tag, ..) ->
      node1tag != node2tag
  }
}

/// Updates the element in-place given the container element, new state, and old
/// state. 
///
/// The `index` argument is used recursively and should be 0 using this function
/// externally.
pub fn update_element(
  parent: DOMElement,
  new new_node: Option(VNode),
  old old_node: Option(VNode),
  index index: Int,
) {
  case new_node, old_node {
    Some(new_node), None -> append_child(parent, create(new_node))
    None, Some(old_node) ->
      remove_child(parent, child_node_at_index_unchecked(parent, index))
    Some(new_node), Some(old_node) ->
      case changed(new_node, old_node) {
        True ->
          replace_child(
            parent,
            create(new_node),
            child_node_at_index_unchecked(parent, index),
          )
        False -> {
          case new_node, old_node {
            Element(children: new_node_children, ..), Element(
              children: old_node_children,
              ..,
            ) -> {
              let new_length = list.length(new_node_children)
              let old_length = list.length(old_node_children)
              let m = int.min(new_length, old_length)
              iterator.range(from: 0, to: m)
              |> iterator.to_list()
              |> list.map(fn(i) {
                let new_node_child =
                  list.at(in: new_node_children, get: i)
                  |> option.from_result()
                let old_node_child =
                  list.at(in: old_node_children, get: i)
                  |> option.from_result()
                update_element(
                  child_node_at_index_unchecked(parent, index),
                  new_node_child,
                  old_node_child,
                  i,
                )
              })
              Nil
            }
          }
          Nil
        }
      }
    None, None ->
      // Do nothing
      Nil
  }
}
