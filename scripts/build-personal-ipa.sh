#!/usr/bin/env bash
# Build a personal, unsigned MaskPad IPA on this Mac from pinned upstream source.
#
# Usage: scripts/build-personal-ipa.sh --output PATH.ipa [--work DIR]
#
# Runs the maintained steps in order: repository safety check, pinned source
# checkout, MaskPad patches and overlays, device configuration, build, and the
# audited unsigned package. No ROM is needed to build; import yours in the app.
# Stage events are appended as JSON lines to DIR/logs/progress.jsonl (default
# DIR: build-personal/) for PadForge and other frontends. The IPA contains code
# compiled from the 2 Ship 2 Harkinian decompilation: keep it private.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUTPUT=""
WORK="$ROOT/build-personal"

usage() {
    echo "Usage: $0 --output PATH.ipa [--work DIR]" >&2
    exit 2
}

while [ $# -gt 0 ]; do
    case "$1" in
        --output) [ $# -ge 2 ] || usage; OUTPUT="$2"; shift 2 ;;
        --work) [ $# -ge 2 ] || usage; WORK="$2"; shift 2 ;;
        *) usage ;;
    esac
done
[ -n "$OUTPUT" ] || usage
case "$OUTPUT" in
    /*) ;;
    *) OUTPUT="$PWD/$OUTPUT" ;;
esac

mkdir -p "$WORK/logs"
EVENTS="$WORK/logs/progress.jsonl"
START=$SECONDS

emit() {
    printf '{"schema_version":1,"event":"%s","stage":"%s","elapsed_seconds":%d}\n' \
        "$1" "$2" "$((SECONDS - START))" >> "$EVENTS"
}

stage() {
    local name="$1"
    shift
    emit stage_started "$name"
    if "$@"; then
        emit stage_completed "$name"
    else
        local code=$?
        emit stage_failed "$name"
        exit "$code"
    fi
}

stage preflight "$ROOT/scripts/check-repo-safety.sh"
stage dependencies "$ROOT/scripts/clone-sources.sh"
stage patch "$ROOT/scripts/apply-patches.sh"
if [ -d "${MASKPAD_IOS_BUILD_DIR:-$ROOT/build-ios-device}" ]; then
    emit stage_skipped configure
else
    stage configure "$ROOT/scripts/configure-ios.sh" --device
fi
stage compile "$ROOT/scripts/build-ios.sh" --device
stage package "$ROOT/scripts/package-unsigned-ipa.sh" \
    "$ROOT/build-ios-device/mm/Release-iphoneos/MaskPad.app" "$OUTPUT"
echo "Personal unsigned IPA: $OUTPUT"

