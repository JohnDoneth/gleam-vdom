import gleam_vdom.{Element, Node, Text}
import gleam/list
import gleam/option.{None, Option, Some}
import gleam/io
import gleam/int
import gleam/iterator

pub external type DOMElement

external fn create_text_node(String) -> DOMElement =
  "./browser_ffi.js" "createTextNode"

external fn create_element(String) -> DOMElement =
  "./browser_ffi.js" "createElement"

external fn append_child(DOMElement, DOMElement) -> Nil =
  "./browser_ffi.js" "appendChild"

external fn child_node_at_index_unchecked(DOMElement, Int) -> DOMElement =
  "./browser_ffi.js" "childNodeAtIndexUnchecked"

external fn remove_child(DOMElement, DOMElement) -> Nil =
  "./browser_ffi.js" "removeChild"

external fn replace_child(DOMElement, DOMElement, DOMElement) -> Nil =
  "./browser_ffi.js" "replaceChild"

pub external fn log(anything) -> Nil =
  "" "console.log"

pub external fn outer_html(DOMElement) -> String =
  "./browser_ffi.js" "outerHTML"

pub fn create(node: Node) -> DOMElement {
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

pub fn changed(node1: Node, node2: Node) -> Bool {
  case node1, node2 {
    Text(_), Element(..) -> True
    Element(..), Text(_) -> True
    Text(a), Text(b) -> a != b
    Element(tag: node1tag, ..), Element(tag: node2tag, ..) ->
      node1tag != node2tag
  }
}

/// Updates the element in place given the container element, old state, and new
/// state.
pub fn update_element(
  parent: DOMElement,
  new_node: Option(Node),
  old_node: Option(Node),
  index: Int,
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
              let m = int.max(new_length, old_length)
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
