/// Initializes the JSDOM library for working with a mocked DOM.
///
/// Must be called before invoking any DOM manipulation functions when
/// running in the NodeJS environment.
pub external fn init() -> Nil =
  "./jsdom_ffi.js" "init"
