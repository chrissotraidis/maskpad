#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SOURCE="$ROOT/sources/2ship2harkinian"
BUILD="${MASKPAD_HOST_BUILD_DIR:-$ROOT/build-host}"

"$ROOT/scripts/apply-patches.sh"
cmake -S "$SOURCE" -B "$BUILD" -G Ninja -DCMAKE_BUILD_TYPE=Release
cmake --build "$BUILD" --target Generate2ShipOtr

ARCHIVE="$SOURCE/mm/2ship.o2r"
if [ ! -s "$ARCHIVE" ]; then
    echo "ROM-free port archive was not generated at $ARCHIVE" >&2
    exit 1
fi
unzip -tq "$ARCHIVE" >/dev/null
echo "ROM-free port archive: $ARCHIVE ($(wc -c < "$ARCHIVE") bytes)"
