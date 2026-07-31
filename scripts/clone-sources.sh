#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SOURCE="$ROOT/sources/2ship2harkinian"
source "$ROOT/scripts/pins.sh"

assert_sha() {
    local directory="$1"
    local expected="$2"
    local actual
    actual="$(git -C "$directory" rev-parse HEAD)"
    if [ "$actual" != "$expected" ]; then
        echo "Pin mismatch in $directory: expected $expected, found $actual" >&2
        exit 1
    fi
}

if [ ! -d "$SOURCE/.git" ]; then
    mkdir -p "$ROOT/sources"
    git clone --no-checkout "$MASKPAD_UPSTREAM" "$SOURCE"
fi

git -C "$SOURCE" fetch origin "$MASKPAD_2S2H_SHA"
git -C "$SOURCE" checkout --detach "$MASKPAD_2S2H_SHA"
git -C "$SOURCE" submodule update --init --recursive

assert_sha "$SOURCE" "$MASKPAD_2S2H_SHA"
assert_sha "$SOURCE/libultraship" "$MASKPAD_LUS_SHA"
assert_sha "$SOURCE/ZAPDTR" "$MASKPAD_ZAPDTR_SHA"
assert_sha "$SOURCE/OTRExporter" "$MASKPAD_OTREXPORTER_SHA"

git -C "$SOURCE" remote set-url --push origin disabled://maskpad-upstream-input
git -C "$SOURCE" submodule foreach --recursive \
    'git remote set-url --push origin disabled://maskpad-upstream-input'

echo "Pinned 2S2H sources are ready at $SOURCE"
