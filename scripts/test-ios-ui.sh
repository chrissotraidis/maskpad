#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BUILD="${MASKPAD_IOS_BUILD_DIR:-$ROOT/build-ios-simulator}"

if [ "$#" -eq 0 ]; then
    echo "Usage: $0 <simulator-udid> [simulator-udid ...]" >&2
    exit 2
fi

MASKPAD_BUILD_UI_TESTS=1 "$ROOT/scripts/configure-ios.sh" --simulator

for udid in "$@"; do
    xcrun simctl bootstatus "$udid" -b
    xcodebuild \
        -quiet \
        -project "$BUILD/2s2h.xcodeproj" \
        -scheme 2ship \
        -configuration Release \
        -destination "platform=iOS Simulator,id=$udid" \
        -only-testing:MaskPadUITests/MaskPadUITests/testControlPressReleaseToggleAndLifecycleCancellation \
        -only-testing:MaskPadUITests/MaskPadUITests/testMoveResizeClampProtectionResetAndPersistence \
        test
done
