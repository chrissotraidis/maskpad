#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SOURCE="$ROOT/sources/2ship2harkinian"
ARTIFACT="${1:-}"
IPA=""
source "$ROOT/scripts/pins.sh"

"$ROOT/scripts/check-repo-safety.sh"

assert_sha() {
    local directory="$1"
    local expected="$2"
    test "$(git -C "$directory" rev-parse HEAD)" = "$expected"
}

if [ -d "$SOURCE/.git" ]; then
    assert_sha "$SOURCE" "$MASKPAD_2S2H_SHA"
    assert_sha "$SOURCE/libultraship" "$MASKPAD_LUS_SHA"
    assert_sha "$SOURCE/ZAPDTR" "$MASKPAD_ZAPDTR_SHA"
    assert_sha "$SOURCE/OTRExporter" "$MASKPAD_OTREXPORTER_SHA"
    git -C "$SOURCE" apply --reverse --check "$ROOT/patches/2ship-ios.patch"
    git -C "$SOURCE/libultraship" apply --reverse --check \
        "$ROOT/patches/libultraship-ios.patch"
    git -C "$SOURCE/ZAPDTR" apply --reverse --check \
        "$ROOT/patches/zapdtr-ios.patch"
    diff -q "$ROOT/port/CMake/ios.cmake" "$SOURCE/CMake/ios.cmake" >/dev/null
    diff -qr "$ROOT/ios" "$SOURCE/mm/ios" >/dev/null
fi

if [ -n "$ARTIFACT" ]; then
    if [ -d "$ARTIFACT" ] && [[ "$ARTIFACT" == *.app ]]; then
        APP="$ARTIFACT"
    elif [ -f "$ARTIFACT" ] && [[ "$ARTIFACT" == *.ipa ]]; then
        STAGING="$(mktemp -d)"
        trap 'rm -rf "$STAGING"' EXIT
        unzip -q "$ARTIFACT" -d "$STAGING"
        APP="$STAGING/Payload/MaskPad.app"
        IPA="$ARTIFACT"
    else
        echo "Expected a MaskPad .app or .ipa: $ARTIFACT" >&2
        exit 1
    fi

    test -x "$APP/MaskPad"
    test "$(plutil -extract CFBundleDisplayName raw "$APP/Info.plist")" = "MaskPad"
    test "$(plutil -extract CFBundleIdentifier raw "$APP/Info.plist")" = \
        "${MASKPAD_BUNDLE_ID:-com.chrissotraidis.maskpad}"
    test -s "$APP/2ship.o2r"
    unzip -tq "$APP/2ship.o2r" >/dev/null
    if unzip -Z1 "$APP/2ship.o2r" |
        grep -Eiq '\.(z64|n64|v64|rom)$|(^|/)mm\.o2r$|\.otr$'; then
        echo "ROM-free 2ship.o2r contains prohibited game data." >&2
        exit 1
    fi
    if find "$APP" -type f |
        grep -Ei '/mm\.o2r$|\.(z64|n64|v64|rom|mobileprovision|p12|p8|pem|key)$' >/dev/null; then
        echo "Artifact contains game data or signing material." >&2
        exit 1
    fi
    if [ -n "$IPA" ]; then
        entries="$(unzip -Z1 "$IPA")"
        grep -Fxq 'RIGHTS_AND_LICENSES.md' <<< "$entries"
        grep -Fq 'ThirdPartyLicenses/' <<< "$entries"
        if grep -Eiq '\.(z64|n64|v64|rom)$|Payload/.*/mm\.o2r$|\.otr$' \
            <<< "$entries"; then
            echo "IPA contains ROM or ROM-derived data." >&2
            exit 1
        fi
    fi
    lipo -info "$APP/MaskPad"
fi

echo "MaskPad release verification passed."
