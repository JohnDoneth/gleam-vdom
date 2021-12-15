//// Module for interfacing with the NodeJS [assert](https://nodejs.org/api/assert.html) functions.

pub external fn should_equal(anything, anything) -> Nil =
  "./node_assert_ffi.js" "shouldEqual"
