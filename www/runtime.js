import { WASI } from "https://cdn.jsdelivr.net/npm/@runno/wasi@0.7.0/dist/wasi.js";
import ghc_wasm_jsffi from "./ghc_wasm_jsffi.js";

export async function runWASM() {
  // 1. Fetch some file (or files) from your server or CDN
  const resp = await fetch("/lib/num.disco");
  const buf = await resp.arrayBuffer();
  
  const fs = {
    "/lib/num.disco": {
      path: "/lib/num.disco",
      timestamps: {
        access: new Date(),
        change: new Date(),
        modification: new Date(),
      },
      mode: "string",               // or "string" if text
      content: new Uint8Array(buf), // bytes of the file
    },
    // ... you can add more files / nested directories similarly
  };

  const wasi = new WASI({
      env: {
        disco_datadir: "lib"
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