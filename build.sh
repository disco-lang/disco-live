#!/usr/bin/env bash
set -e

wasm32-wasi-cabal build disco-live
wasm32-wasi-cabal list-bin exe:disco-live
EXE_WASM="$(wasm32-wasi-cabal list-bin exe:disco-live)"
cp -f "$EXE_WASM" "www/disco-live.wasm"

"$(wasm32-wasi-ghc --print-libdir)"/post-link.mjs \
  --input "$EXE_WASM" --output "www/ghc_wasm_jsffi.js"
