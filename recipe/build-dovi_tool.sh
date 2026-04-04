#!/usr/bin/env bash
set -exuo pipefail

cd "${SRC_DIR}/dovi_tool_src"

if [[ -z "${CARGO_BUILD_TARGET:-}" && -n "${RUST_TARGET:-}" ]]; then
    export CARGO_BUILD_TARGET="${RUST_TARGET}"
fi

# On Linux, force fontconfig dlopen mode to avoid pkg-config probing during Cargo builds.
if [[ "${target_platform:-}" == linux-* ]]; then
    export RUST_FONTCONFIG_DLOPEN=1
fi

if [[ -n "${CARGO_BUILD_TARGET:-}" && "${build_platform:-}" != "${target_platform:-}" ]]; then
    # Help Rust crates that use cc-rs pick the conda-forge target compiler names
    # instead of probing for non-existent upstream triplets like aarch64-linux-gnu-g++.
    rust_target_env="${CARGO_BUILD_TARGET//-/_}"
    export TARGET_CC="${CC}"
    export TARGET_CXX="${CXX:-${CC}}"
    export "CC_${rust_target_env}=${CC}"
    export "CXX_${rust_target_env}=${CXX:-${CC}}"
fi

export CARGO_PROFILE_RELEASE_STRIP=symbols
export CARGO_PROFILE_RELEASE_LTO=thin

cargo-bundle-licenses \
    --format yaml \
    --output "${SRC_DIR}/THIRDPARTY_dovi_tool.yml"

cargo auditable install \
    --locked \
    --no-track \
    --bins \
    --root "${PREFIX}" \
    --path .
