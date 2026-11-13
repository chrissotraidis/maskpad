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
    shift 2
    local upgrade
    if git -C "$directory" apply --reverse --check "$patch" >/dev/null 2>&1; then
        echo "Already applied: $(basename "$patch")"
    elif git -C "$directory" apply --check "$patch"; then
        git -C "$directory" apply "$patch"
        echo "Applied: $(basename "$patch")"
    elif [ $# -gt 0 ]; then
        # A checkout patched by an earlier version: add each missing follow-up
        # in order, then require the complete patch.
        for upgrade in "$@"; do
            if git -C "$directory" apply --check "$upgrade" 2>/dev/null; then
                git -C "$directory" apply "$upgrade"
            fi
        done
        git -C "$directory" apply --reverse --check "$patch" || {
            echo "Upgrade did not produce the complete patch; source edits were preserved: $patch" >&2
            exit 1
        }
        echo "Upgraded: $(basename "$patch")"
    else
        echo "Patch does not match the pinned source: $patch" >&2
        exit 1
    fi
}

# 2ship-touch-autohide.patch upgrades checkouts patched before touch auto-hide.
apply_patch_once "$SOURCE" "$ROOT/patches/2ship-ios.patch" \
    "$ROOT/patches/2ship-touch-autohide.patch"
# libultraship-ios.patch includes SDL 2.32.10 scene startup (apps built with the
# iOS 27 SDK need it to open); the scenes patch upgrades checkouts made before it.
apply_patch_once "$SOURCE/libultraship" "$ROOT/patches/libultraship-ios.patch" \
    "$ROOT/patches/libultraship-uikit-scenes.patch" \
    "$ROOT/patches/libultraship-sdl2-window-ownership.patch"
apply_patch_once "$SOURCE/ZAPDTR" "$ROOT/patches/zapdtr-ios.patch"

mkdir -p "$SOURCE/CMake" "$SOURCE/mm/ios"
cp "$ROOT/port/CMake/ios.cmake" "$SOURCE/CMake/ios.cmake"
rsync -a --checksum --delete "$ROOT/ios/" "$SOURCE/mm/ios/"

diff -q "$ROOT/port/CMake/ios.cmake" "$SOURCE/CMake/ios.cmake" >/dev/null
diff -qr "$ROOT/ios" "$SOURCE/mm/ios" >/dev/null
echo "MaskPad overlays and patches match the source checkout."
