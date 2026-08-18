#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
APP="${1:-$ROOT/build-ios-device/mm/Release-iphoneos/MaskPad.app}"
OUTPUT="${2:-$ROOT/artifacts/MaskPad-0.1.2-unsigned.ipa}"

if [[ "$APP" != /* ]]; then
    APP="$ROOT/$APP"
fi
if [[ "$OUTPUT" != /* ]]; then
    OUTPUT="$ROOT/$OUTPUT"
fi

if [ ! -d "$APP" ]; then
    echo "Device app not found: $APP" >&2
    exit 1
fi
if plutil -extract CFBundleSupportedPlatforms.0 raw "$APP/Info.plist" |
    grep -q "iPhoneSimulator"; then
    echo "Refusing to package a Simulator app as an IPA." >&2
    exit 1
fi
if [ -e "$APP/embedded.mobileprovision" ]; then
    echo "Refusing to package provisioning data." >&2
    exit 1
fi
if find "$APP" -type f |
    grep -Ei '/mm\.o2r$|\.(z64|n64|v64|rom|mobileprovision|p12|p8|pem|key)$' >/dev/null; then
    echo "Refusing to package game data or signing material." >&2
    exit 1
fi
if codesign --verify --strict "$APP" >/dev/null 2>&1 ||
   [ -d "$APP/_CodeSignature" ]; then
    echo "Refusing a signed or stale-signed app in the unsigned packager." >&2
    exit 1
fi
if [ ! -f "$ROOT/RIGHTS_AND_LICENSES.md" ]; then
    echo "Required rights and licensing notice is missing." >&2
    exit 1
fi

STAGING="$(mktemp -d)"
trap 'rm -rf "$STAGING"' EXIT
mkdir -p "$STAGING/Payload" "$(dirname "$OUTPUT")"
ditto "$APP" "$STAGING/Payload/MaskPad.app"
cp "$ROOT/RIGHTS_AND_LICENSES.md" "$STAGING/RIGHTS_AND_LICENSES.md"

LICENSES="$STAGING/ThirdPartyLicenses"
license_count=0
mkdir "$LICENSES"
while IFS= read -r -d '' license_file; do
    relative="${license_file#"$ROOT/"}"
    destination="$LICENSES/$relative"
    mkdir -p "$(dirname "$destination")"
    cp "$license_file" "$destination"
    license_count=$((license_count + 1))
done < <(
    find "$ROOT/sources/2ship2harkinian" "$ROOT/build-ios-device/_deps" \
        -type f \
        \( -iname 'LICENSE*' -o -iname 'COPYING*' -o -iname 'NOTICE*' \) \
        -print0 | sort -z
)
if [ "$license_count" -eq 0 ]; then
    echo "No third-party license files were found for packaging." >&2
    exit 1
fi

rm -f "$OUTPUT"
(cd "$STAGING" && zip -qry "$OUTPUT" Payload RIGHTS_AND_LICENSES.md ThirdPartyLicenses)
unzip -tq "$OUTPUT" >/dev/null
entries="$(unzip -Z1 "$OUTPUT")"
grep -Fxq 'Payload/MaskPad.app/MaskPad' <<< "$entries"
grep -Fxq 'RIGHTS_AND_LICENSES.md' <<< "$entries"
grep -Fq 'ThirdPartyLicenses/' <<< "$entries"
if grep -Eiq '\.(z64|n64|v64|rom)$|Payload/.*/mm\.o2r$|\.otr$' \
    <<< "$entries"; then
    echo "Refusing IPA containing ROM or ROM-derived data." >&2
    exit 1
fi
echo "$OUTPUT"
shasum -a 256 "$OUTPUT"
