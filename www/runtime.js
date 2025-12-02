import { WASI } from "https://cdn.jsdelivr.net/npm/@runno/wasi@0.7.0/dist/wasi.js";
import ghc_wasm_jsffi from "./ghc_wasm_jsffi.js";

export async function runWASM() {
  const addLibFile = async (name, result) => {
  // 1. Fetch some file (or files) from your server or CDN
    const urlpath = "stdlib/" + name + ".disco";
    const filename = "/" + urlpath;
    const resp = await fetch(urlpath);
    const buf = await resp.arrayBuffer();

    result[filename] = {
      path: filename,
      timestamps: {
        access: new Date(),
        change: new Date(),
        modification: new Date(),
      },
      mode: "bytes",               // or "string" if text
      content: new Uint8Array(buf), // bytes of the file
    };
  };
  const fs = {};
  await addLibFile("container", fs);
  await addLibFile("graph", fs);
  await addLibFile("list", fs);
  await addLibFile("num", fs);
  await addLibFile("prim", fs);
  await addLibFile("product", fs);
  await addLibFile("prop", fs);
  await addLibFile("string", fs);

  const wasi = new WASI({
      env: {
        disco_datadir: "stdlib"
      },
      fs: fs,
      stdout: (out) => console.log("[wasm stdout]", out),
  });

  const jsffiExports = {};
  const wasm = await WebAssembly.instantiateStreaming(
      fetch('./disco-live.wasm'),
      Object.assign(
          { ghc_wasm_jsffi: ghc_wasm_jsffi(jsffiExports) },
          wasi.getImportObject()
      )
  );
  Object.assign(jsffiExports, wasm.instance.exports);

  wasi.initialize(wasm, {
      ghc_wasm_jsffi: ghc_wasm_jsffi(jsffiExports)
  });
  wasi.instance.exports.setup();

};