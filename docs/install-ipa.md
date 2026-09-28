# Build and install MaskPad

Prebuilt MaskPad downloads have been retired. Build your own unsigned IPA on
an Apple Silicon Mac, then re-sign it with a personal sideload tool. It is not
an App Store or TestFlight build.

The IPA does not include a ROM or generated game data; you import your own ROM
in the app. It does contain code compiled from the 2 Ship 2 Harkinian
decompilation, so keep your personal build private and do not share it.

## Build and package

Install the requirements in [building.md](building.md), then run one command
from a clean checkout:

```sh
scripts/build-personal-ipa.sh --output artifacts/MaskPad-personal-unsigned.ipa
```

It runs the repository safety check, fetches the pinned upstream source,
applies MaskPad's patches, builds for iPhone/iPad, and packages an unsigned
IPA. Stage events are written to `build-personal/logs/progress.jsonl`. The
individual steps remain available:

```sh
scripts/clone-sources.sh
scripts/apply-patches.sh
scripts/configure-ios.sh --device
scripts/build-ios.sh --device
scripts/package-unsigned-ipa.sh
scripts/verify-release.sh artifacts/MaskPad-0.1.2-unsigned.ipa
```

The result is `artifacts/MaskPad-0.1.2-unsigned.ipa`. Verify its SHA-256
against the value printed by the packaging command.

## Re-sign and install

Use a sideload tool you trust, such as AltStore Classic, and follow its
current official documentation. The general flow is:

1. Configure the tool with your own Apple ID and device.
2. On iOS or iPadOS 16 and later, enable **Developer Mode** if required.
3. Select your locally built unsigned IPA.
4. Allow the tool to re-sign and install it.
5. Launch MaskPad once, then follow the README's
   [first-launch instructions](../README.md#first-launch).

MaskPad never receives your Apple ID credentials. Signing is handled by the
tool you choose and Apple.

## Refresh and update

Personal signatures can expire and may need periodic refresh. To preserve the
Files-visible Documents container during an update:

1. Back up the MaskPad folder in Files.
2. Re-sign the newer IPA using the same account and bundle identifier.
3. Install it in place instead of deleting the existing app first.

Signed installation and an in-place update have preserved app data on the
tested physical iPad. Personal-sideload installation, signature renewal, and
container preservation through tools such as AltStore Classic remain
unverified MaskPad gates. A sideload tool can still replace an app container,
so keep backups of saves and generated data.
