import dom.{DOMElement}

pub external fn set_global(Bool) -> Nil =
  "./testing_ffi.js" "setGlobal"

pub external fn get_global() -> Bool =
  "./testing_ffi.js" "getGlobal"

pub external fn click(anything) -> Nil =
  "./testing_ffi.js" "click"

pub external fn child_node_at_index_unchecked(DOMElement, Int) -> DOMElement =
  "./dom_ffi.js" "childNodeAtIndexUnchecked"
