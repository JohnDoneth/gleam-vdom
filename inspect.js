/// Inspect function copied from generated "gleam.js"
export function inspect(v) {
  let t = typeof v;
  if (v === true) return "True";
  if (v === false) return "False";
  if (v === null) return "//js(null)";
  if (v === undefined) return "Nil";
  if (t === "string") return JSON.stringify(v);
  if (t === "bigint" || t === "number") return v.toString();
  if (Array.isArray(v)) return `#(${v.map(inspect).join(", ")})`;
  if (v instanceof Set) return `//js(Set(${[...v].map(inspect).join(", ")}))`;
  if (v instanceof RegExp) return `//js(${v})`;
  if (v instanceof Date) return `//js(Date("${v.toISOString()}"))`;
  if (v instanceof Function) {
    let args = [];
    for (let i of Array(v.length).keys())
      args.push(String.fromCharCode(i + 97));
    return `//fn(${args.join(", ")}) { ... }`;
  }
  try {
    return v.inspect();
  } catch (_) {
    return inspectObject(v);
  }
}

function inspectObject(v) {
  let [keys, get] = getters(v);
  let name = v.constructor.name;
  let props = [];
  for (let k of keys(v)) {
    props.push(`${inspect(k)}: ${inspect(get(v, k))}`);
  }
  let body = props.length ? " " + props.join(", ") + " " : "";
  let head = name === "Object" ? "" : name + " ";
  return `//js(${head}{${body}})`;
}
