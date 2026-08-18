#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SOURCE="$ROOT/sources/2ship2harkinian/libultraship"

if ! git -C "$SOURCE" rev-parse --git-dir >/dev/null 2>&1; then
    echo "Run scripts/clone-sources.sh and scripts/apply-patches.sh first." >&2
    exit 1
fi

if ! git -C "$SOURCE" apply --reverse --check "$ROOT/patches/libultraship-ios.patch" >/dev/null 2>&1; then
    echo "The maintained libultraship patch is not applied." >&2
    exit 1
fi

TEST_BINARY="$(mktemp -t maskpad-controller-test.XXXXXX)"
trap 'rm -f "$TEST_BINARY"' EXIT

"${CXX:-clang++}" -std=c++20 -Wall -Wextra -Werror \
    -I"$ROOT/tests/fakes" \
    -I"$SOURCE/include" \
    "$ROOT/tests/controller_reconnect_test.cpp" \
    "$SOURCE/src/ship/controller/physicaldevice/ConnectedPhysicalDeviceManager.cpp" \
    -o "$TEST_BINARY"

"$TEST_BINARY"
