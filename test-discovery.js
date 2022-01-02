import { inspect } from "./inspect.js";

// function inspect(any) {
//   console.log(any);
//   return any;
// }

function green(text) {
  return "\x1B[32m" + text + "\x1B[39m";
}

function red(text) {
  return "\x1B[31m" + text + "\x1B[39m";
}

//
// Imports the compiled test module file and executes functions with names
// ending with `_test`.
//
async function importTestsFromModules(modulePaths) {
  const modules = await Promise.all(
    modulePaths.map((module_path) => import(module_path))
  );

  return Object.fromEntries(
    modules
      .map((module) => Object.entries(module))
      .flat()
      .filter(([function_name, _value]) => function_name.endsWith("_test"))
  );
}

function stringify(anything) {
  if (typeof anything == "object") {
    return JSON.stringify(anything);
  } else {
    return anything.toString();
  }
}

console.log("running tests");

let tests = await importTestsFromModules([
  "./target/lib/gleam_vdom/vdom_test.js",
  "./target/lib/gleam_vdom/diff_test.js",
  "./target/lib/gleam_vdom/dom_test.js",
]);

let anyFailed = false;

Object.entries(tests).forEach(([test_name, test]) => {
  try {
    process.stdout.write(`test ${test_name}`);
    test.call();
    process.stdout.write(` ${green("passed ✔️")}\n`);
  } catch (e) {
    if (e.expected && e.actual) {
      console.log(
        ` ${red("failed ❌")} \n\tExpected: ${inspect(
          e.expected
        )}\n\tActual:   ${inspect(e.actual)}\n`
      );
    } else {
      process.stdout.write(` ${red("failed:")}\n`);
      console.log("\t" + e);
    }
    anyFailed = true;
  }
});

if (anyFailed) {
  process.exit(1);
}
