# Install the MaskPad IPA

MaskPad's packaging script creates an unsigned IPA. It is not an App Store or
TestFlight build. A personal sideload tool must re-sign it with your Apple ID
before installation on an iPhone or iPad.

The IPA does not include Majora's Mask, a ROM, or generated game data.

## Download and verify

Download both files from the current [`v0.1.1` GitHub
release](https://github.com/chrissotraidis/maskpad/releases/tag/v0.1.1):

- `MaskPad-0.1.1-unsigned.ipa`
- `MaskPad-0.1.1-unsigned.ipa.sha256`

From the directory containing both downloads, verify the package before
installing it:

```sh
shasum -a 256 -c MaskPad-0.1.1-unsigned.ipa.sha256
```

The command must report `MaskPad-0.1.1-unsigned.ipa: OK`.

## Build and package

On the Mac used for development:

```sh
scripts/clone-sources.sh
scripts/apply-patches.sh
scripts/configure-ios.sh --device
scripts/build-ios.sh --device
scripts/package-unsigned-ipa.sh
scripts/verify-release.sh artifacts/MaskPad-0.1.1-unsigned.ipa
```

The result is `artifacts/MaskPad-0.1.1-unsigned.ipa`. Verify its SHA-256
against the value printed by the packaging command.

## Re-sign and install

Use a sideload tool you trust, such as AltStore Classic, and follow its
current official documentation. The general flow is:

1. Configure the tool with your own Apple ID and device.
2. On iOS or iPadOS 16 and later, enable **Developer Mode** if required.
3. Select the downloaded or locally built unsigned IPA.
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
