//// Contains the pure virtual DOM representation `VDOM` and functions for
//// interacting with it.

import gleam/map.{Map}
import gleam/string
import gleam/list
import gleam/dynamic.{Dynamic}

/// Represents a virtual DOM element. 
///
/// It is considered "virtual" as it only / represents the state the DOM will be
/// in once it is applied to the browser by patching. See the `dom` module for those functions.
///
/// The `diff` module uses these VDOM elements as well, by producing `diffs`. Diffs are a
/// minimal set of changes which can be applied to the real DOM to conform it to
/// the provided VDOM with minimal API calls to the browser itself.
pub type VDOM {
  /// Element with a tag with optional attributes and children.
  Element(tag: String, attributes: Map(String, Attribute), children: List(VDOM))
  /// Text element.
  Text(value: String)
}

/// Type constraining the different types of attribute values.
pub type Attribute {
  /// A String attribute.
  AText(String)
  /// A boolean attribute.
  ABool(Bool)
  /// An event listener.
  AEventListener(fn(Dynamic) -> Nil)
}

pub fn attribute_to_string(attribute: Attribute) -> String {
  case attribute {
    AText(text) -> text
    ABool(True) -> "true"
    ABool(False) -> "false"
  }
}

/// Render a `VDOM` to its HTML representation.
pub fn to_html(node: VDOM) -> String {
  case node {
    Element(tag: tag, attributes: attributes, children: children) -> {
      let rendered_body =
        children
        |> list.map(with: to_html)
        |> list.fold(from: "", with: string.append)
      let rendered_attributes =
        attributes
        |> map.fold(
          from: "",
          with: fn(acc, key, value) {
            let rvalue =
              "\""
              |> string.append(attribute_to_string(value))
              |> string.append("\"")
            let pair =
              key
              |> string.append("=")
              |> string.append(rvalue)
            string.append(acc, string.append(" ", pair))
          },
        )
      string.append("<", tag)
      |> string.append(rendered_attributes)
      |> string.append(">")
      |> string.append(rendered_body)
      |> string.append("</")
      |> string.append(tag)
      |> string.append(">")
    }

    Text(value: value) -> value
  }
}

/// Helper function for creating a virtual DOM element.
pub fn element(
  tag: String,
  attributes: List(#(String, Attribute)),
  children: List(VDOM),
) -> VDOM {
  Element(tag: tag, attributes: map.from_list(attributes), children: children)
}

/// Same as `element` without children.
pub fn element_(tag: String, attributes: List(#(String, Attribute))) -> VDOM {
  Element(tag: tag, attributes: map.from_list(attributes), children: [])
}

/// Helper function for creating a virtual text element.
pub fn text(value: String) -> VDOM {
  Text(value: value)
}
