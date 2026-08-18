#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SOURCE="$ROOT/sources/2ship2harkinian"
MODE="${1:---simulator}"
DEPLOYMENT_TARGET="${MASKPAD_DEPLOYMENT_TARGET:-14.0}"
BUNDLE_ID="${MASKPAD_BUNDLE_ID:-com.chrissotraidis.maskpad}"
VERSION="${MASKPAD_VERSION:-0.1.2}"
BUILD_NUMBER="${MASKPAD_BUILD_NUMBER:-3}"
BUILD_UI_TESTS=OFF
if [ "${MASKPAD_BUILD_UI_TESTS:-0}" = "1" ]; then
    BUILD_UI_TESTS=ON
fi

case "$MODE" in
    --simulator)
        PLATFORM="SIMULATORARM64"
        BUILD="${MASKPAD_IOS_BUILD_DIR:-$ROOT/build-ios-simulator}"
        ;;
    --device)
        PLATFORM="OS64"
        BUILD="${MASKPAD_IOS_BUILD_DIR:-$ROOT/build-ios-device}"
        ;;
    *)
        echo "Usage: $0 [--simulator|--device]" >&2
        exit 2
        ;;
esac

"$ROOT/scripts/generate-port-archive.sh"
cmake -S "$SOURCE" -B "$BUILD" -G Xcode \
    -DCMAKE_SYSTEM_NAME=iOS \
    -DPLATFORM="$PLATFORM" \
    -DDEPLOYMENT_TARGET="$DEPLOYMENT_TARGET" \
    -DBUNDLE_ID:STRING="$BUNDLE_ID" \
    -DMASKPAD_VERSION="$VERSION" \
    -DMASKPAD_BUILD_NUMBER="$BUILD_NUMBER" \
    -DMASKPAD_BUILD_UI_TESTS="$BUILD_UI_TESTS" \
    -DCMAKE_XCODE_GENERATE_SCHEME=ON

echo "Configured $PLATFORM at $BUILD"
