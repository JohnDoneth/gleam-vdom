# gleam_vdom

[![test](https://github.com/JohnDoneth/gleam-vdom/actions/workflows/test.yml/badge.svg)](https://github.com/JohnDoneth/gleam-vdom/actions/workflows/test.yml)

Gleam library for working with [Virtual DOMs](https://en.wikipedia.org/wiki/Virtual_DOM).

## Usage

Producing a diff from two virtual DOMs

```gleam
diff(
    new: Some(element("div", [], [text("new_text")])),
    old: Some(element("div", [], [text("old_text")])),
)

[
    ChildDiff(
    index: 0,
    attr_diff: [],
    diff: [ReplaceText(index: 0, text: "new_text")],
    ),
]
```

Patching the browser DOM using a set of diffs.

```gleam
let container: DOMElement = get_element_by_id("#app")

let initial_state: VDOM = element("p", [], [text("starting text")])
let desired_state: VDOM = element("p", [], [text("new text!")])

dom.patch(
    container,
    diff(
        new: Some(initial_state),
        old: None, // None as there are no existing elements.
    )
)

should_equal(dom.outer_html(container), "<div id=\"app\"><p>starting text</p></div>")

dom.patch(
    container,
    diff(
        new: Some(desired_state),
        old: Some(initial_state),
    )
)

should_equal(dom.outer_html(container), "<div id=\"app\"><p>new text!</p></div>")
```

## References

[How to write your own Virtual DOM](https://medium.com/@deathmood/how-to-write-your-own-virtual-dom-ee74acc13060)
