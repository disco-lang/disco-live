#!/usr/bin/env bash
#
# Minimize and package the final .wasm build.
set -e
WDIR="$(mktemp -d)"
trap 'rm -rf -- "$WDIR"' EXIT

EXE_WASM="www/disco-live.wasm"

wizer \
    --allow-wasi --wasm-bulk-memory true --init-func _initialize \
    "$EXE_WASM" -o "$WDIR/exe-init.wasm"
EXE_WASM_FINAL="$WDIR/exe-opt.wasm"
wasm-opt "$WDIR/exe-init.wasm" -o "$EXE_WASM_FINAL" -Oz
wasm-tools strip "$EXE_WASM_FINAL" -o "$EXE_WASM_FINAL"

cp -f "$EXE_WASM_FINAL" www/disco-live.wasm
