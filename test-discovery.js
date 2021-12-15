//
// Imports the compiled test module file and executes functions with names
// ending with `_test`.
//

console.log("running tests");

let module = await import("./target/lib/gleam_vdom/gleam_vdom_test.js");
let keys = Object.keys(module);
let tests = keys.filter((x) => x.endsWith("_test"));

let anyFailed = false;

tests.forEach((test) => {
  try {
    process.stdout.write(`test ${test}`);
    module[test]();
    process.stdout.write(` passed ✔️\n`);
  } catch (e) {
    if (e.expected && e.actual) {
      console.log(
        `test ${test} failed: \n\tExpected: ${e.expected}\n\tActual:   ${e.actual}\n`
      );
    } else {
      process.stdout.write(` failed:\n`);
      console.log("\t" + e);
    }
    anyFailed = true;
  }
});

if (anyFailed) {
  process.exit(1);
}
