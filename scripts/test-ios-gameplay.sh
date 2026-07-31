#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BUILD="${MASKPAD_IOS_BUILD_DIR:-$ROOT/build-ios-simulator}"
BUNDLE_ID="${MASKPAD_BUNDLE_ID:-com.chrissotraidis.maskpad}"

if [ "$#" -eq 0 ]; then
    echo "Usage: $0 <simulator-udid> [simulator-udid ...]" >&2
    exit 2
fi

for udid in "$@"; do
    data_container="$(xcrun simctl get_app_container "$udid" "$BUNDLE_ID" data 2>/dev/null || true)"
    if [ -z "$data_container" ] || [ ! -f "$data_container/Documents/mm.o2r" ]; then
        echo "No user-generated mm.o2r is installed for $udid; gameplay test not run." >&2
        exit 1
    fi
done

MASKPAD_BUILD_UI_TESTS=1 "$ROOT/scripts/configure-ios.sh" --simulator

for udid in "$@"; do
    xcrun simctl bootstatus "$udid" -b
    xcodebuild \
        -quiet \
        -project "$BUILD/2s2h.xcodeproj" \
        -scheme 2ship \
        -configuration Release \
        -destination "platform=iOS Simulator,id=$udid" \
        -only-testing:MaskPadUITests/MaskPadUITests/testGameplayConsumesMappedInputs \
        test
done
