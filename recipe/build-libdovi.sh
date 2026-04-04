#!/usr/bin/env bash
set -exuo pipefail

cd "${SRC_DIR}/libdovi_src/dolby_vision"

if [[ -z "${CARGO_BUILD_TARGET:-}" && -n "${RUST_TARGET:-}" ]]; then
    export CARGO_BUILD_TARGET="${RUST_TARGET}"
fi

cargo-bundle-licenses \
    --format yaml \
    --output "${SRC_DIR}/THIRDPARTY_libdovi.yml"

target_args=()
if [[ -n "${CARGO_BUILD_TARGET:-}" ]]; then
    # cargo-c does not reliably infer the cross target from env alone.
    target_args+=(--target "${CARGO_BUILD_TARGET}")
fi

cargo cinstall \
    --locked \
    --release \
    "${target_args[@]}" \
    --prefix "${PREFIX}" \
    --libdir "${PREFIX}/lib" \
    --includedir "${PREFIX}/include"

rm -f "${PREFIX}/lib/libdovi.a"
