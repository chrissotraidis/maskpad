#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
MODE="${1:---simulator}"

case "$MODE" in
    --simulator)
        BUILD="${MASKPAD_IOS_BUILD_DIR:-$ROOT/build-ios-simulator}"
        SDK="iphonesimulator"
        PRODUCT_DIR="Release-iphonesimulator"
        ;;
    --device)
        BUILD="${MASKPAD_IOS_BUILD_DIR:-$ROOT/build-ios-device}"
        SDK="iphoneos"
        PRODUCT_DIR="Release-iphoneos"
        ;;
    *)
        echo "Usage: $0 [--simulator|--device]" >&2
        exit 2
        ;;
esac

if [ ! -d "$BUILD" ]; then
    "$ROOT/scripts/configure-ios.sh" "$MODE"
fi

APP="$BUILD/mm/$PRODUCT_DIR/MaskPad.app"
# An unsigned rebuild can otherwise retain signing files from a prior local
# device install because Xcode leaves stale bundle contents in place.
rm -rf "$APP/_CodeSignature"
rm -f "$APP/embedded.mobileprovision"

cmake --build "$BUILD" --target 2ship --config Release -- \
    -quiet -sdk "$SDK" CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO

test -x "$APP/MaskPad"
echo "$APP"
