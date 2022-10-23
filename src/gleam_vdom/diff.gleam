//// Module for finding the set of `Diff`s required to to change one `VNode` into
//// another `VNode`. 

import gleam_vdom/vdom.{AEventListener, Attribute, Element, Text, VDOM}
import gleam/option.{None, Option, Some}
import gleam/list
import gleam/int
import gleam/iterator
import gleam/map.{Map}
import gleam/dynamic.{Dynamic}

pub type Diff {
  /// Delete a child node at `index`.
  Delete(index: Int)
  /// Create a child node at `index` from `vdom`.
  Insert(index: Int, vdom: VDOM)
  /// Replace the text content of the child at `index` with `text`.
  ReplaceText(index: Int, text: String)
  /// A list of `diff`s to be applied to the child node at `index`.
  ChildDiff(index: Int, attr_diff: List(AttrDiff), diff: List(Diff))
}

pub type AttrDiff {
  /// Delete attribute with the key of `key`.
  DeleteKey(key: String)
  /// Set the attribute with `key` to the value of `attribute`.
  InsertKey(key: String, attribute: Attribute)
  /// Remove a specific event listener by event type and function value.
  RemoveEventListener(key: String, handler: fn(Dynamic) -> Nil)
}

fn changed(node1: VDOM, node2: VDOM) -> Bool {
  case node1, node2 {
    Text(_), Element(..) -> True
    Element(..), Text(_) -> True
    Text(a), Text(b) -> a != b
    Element(tag: node1tag, ..), Element(tag: node2tag, ..) ->
      node1tag != node2tag
  }
}

/// Computes a list of `Diff`s required to to change the old `VNode` into
/// the new `VNode`. 
pub fn diff(new a: Option(VDOM), old b: Option(VDOM)) -> List(Diff) {
  diff_(new: a, old: b, index: 0, acc: [])
}

fn diff_(
  new new_node: Option(VDOM),
  old old_node: Option(VDOM),
  index index: Int,
  acc acc: List(Diff),
) -> List(Diff) {
  case new_node, old_node {
    Some(new_node), None -> list.append(acc, [Insert(index: 0, vdom: new_node)])
    None, Some(_old_node) -> list.append(acc, [Delete(index: 0)])
    Some(Text(a)), Some(Text(b)) ->
      case a == b {
        True -> acc
        False -> list.append(acc, [ReplaceText(index: index, text: a)])
      }

    Some(new_node), Some(old_node) ->
      case changed(new_node, old_node) {
        True ->
          list.append(acc, [Delete(index: 0), Insert(index: 0, vdom: new_node)])
        False ->
          case new_node, old_node {
            Element(children: new_node_children, attributes: new_attrs, ..), Element(
              children: old_node_children,
              attributes: old_attrs,
              ..,
            ) -> {
              let attr_diff = diff_attributes(new_attrs, old_attrs)
              let result =
                list.append(
                  acc,
                  diff_children(new_node_children, old_node_children, acc),
                )
              case list.length(attr_diff) > 0 {
                True ->
                  list.append(
                    result,
                    [
                      ChildDiff(
                        index: 0,
                        attr_diff: diff_attributes(new_attrs, old_attrs),
                        diff: [],
                      ),
                    ],
                  )
                False -> result
              }
            }
          }
      }

    None, None -> acc
  }
}

fn diff_children(
  new_children: List(VDOM),
  old_children: List(VDOM),
  //attr_diffs: List(AttrDiff),
  acc: List(Diff),
) -> List(Diff) {
  let new_length = list.length(new_children)
  let old_length = list.length(old_children)
  let m = int.min(new_length, old_length)
  let diffs =
    iterator.range(from: 0, to: m)
    |> iterator.to_list()
    |> list.map(fn(i) {
      let new_child =
        list.at(in: new_children, get: i)
        |> option.from_result()
      let old_child =
        list.at(in: old_children, get: i)
        |> option.from_result()

      ChildDiff(
        index: i,
        attr_diff: [],
        diff: diff_(new: new_child, old: old_child, index: i, acc: acc),
      )
    })
}

fn diff_attributes(
  new_attrs: Map(String, Attribute),
  old_attrs: Map(String, Attribute),
) -> List(AttrDiff) {
  let over = list.append(map.to_list(old_attrs), map.to_list(new_attrs))

  list.fold(
    over: over,
    from: [],
    with: fn(acc, v: #(String, Attribute)) {
      let key = v.0
      let value = v.1

      case map.get(new_attrs, key) {
        Ok(new_value) ->
          case new_value == value {
            True ->
              case map.has_key(old_attrs, key) {
                True -> acc
                False ->
                  list.append(acc, [InsertKey(key: key, attribute: new_value)])
              }
            False ->
              list.append(acc, [InsertKey(key: key, attribute: new_value)])
          }
        Error(Nil) ->
          case value {
            AEventListener(handler) ->
              list.append(
                acc,
                [RemoveEventListener(key: key, handler: handler)],
              )
            _ -> list.append(acc, [DeleteKey(key: key)])
          }
      }
    },
  )
}
