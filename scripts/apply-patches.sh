#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SOURCE="$ROOT/sources/2ship2harkinian"

if [ ! -d "$SOURCE/.git" ]; then
    echo "Run scripts/clone-sources.sh first." >&2
    exit 1
fi

apply_patch_once() {
    local directory="$1"
    local patch="$2"
    if git -C "$directory" apply --reverse --check "$patch" >/dev/null 2>&1; then
        echo "Already applied: $(basename "$patch")"
    elif git -C "$directory" apply --check "$patch"; then
        git -C "$directory" apply "$patch"
        echo "Applied: $(basename "$patch")"
    else
        echo "Patch does not match the pinned source: $patch" >&2
        exit 1
    fi
}

apply_patch_once "$SOURCE" "$ROOT/patches/2ship-ios.patch"
apply_patch_once "$SOURCE/libultraship" "$ROOT/patches/libultraship-ios.patch"
apply_patch_once "$SOURCE/ZAPDTR" "$ROOT/patches/zapdtr-ios.patch"

mkdir -p "$SOURCE/CMake" "$SOURCE/mm/ios"
cp "$ROOT/port/CMake/ios.cmake" "$SOURCE/CMake/ios.cmake"
rsync -a --checksum "$ROOT/ios/" "$SOURCE/mm/ios/"

diff -q "$ROOT/port/CMake/ios.cmake" "$SOURCE/CMake/ios.cmake" >/dev/null
diff -qr "$ROOT/ios" "$SOURCE/mm/ios" >/dev/null
echo "MaskPad overlays and patches match the source checkout."
