# Building MaskPad

## Requirements

- Apple Silicon Mac
- Xcode 26 or a compatible Xcode with iOS SDK and command-line tools
- CMake 3.26 or newer
- Ninja
- Git, Python 3, `curl`, `zip`, and `unzip`
- network access for the pinned source and CMake dependencies

No ROM is needed to compile the app or create the ROM-free `2ship.o2r`.

## Reconstruct the exact source

```sh
scripts/clone-sources.sh
scripts/apply-patches.sh
```

The clone is detached at:

| Component | Revision |
|---|---|
| 2 Ship 2 Harkinian 4.0.2 | `acfd617302ebb74e63f26f0049b53400a644c8e8` |
| libultraship | `b2dd85ca393225afb0c949035e0eabf87751ff89` |
| ZAPDTR | `684f21a475dcfeee89938ae1f4afc42768a3e7ef` |
| OTRExporter | `32e088e28c8cdd055d4bb8f3f219d33ad37963f3` |

Push URLs are disabled in every upstream checkout. The checkout is disposable:
the maintained inputs are `patches/`, `port/`, and `ios/`.

## Simulator

```sh
scripts/configure-ios.sh --simulator
scripts/build-ios.sh --simulator
```

The default output is:

`build-ios-simulator/mm/Release-iphonesimulator/MaskPad.app`

Install it with:

```sh
xcrun simctl install booted \
  build-ios-simulator/mm/Release-iphonesimulator/MaskPad.app
xcrun simctl launch booted com.chrissotraidis.maskpad
```

Run the opt-in touch/editor UI suite on representative devices with:

```sh
scripts/test-ios-ui.sh <ipad-simulator-udid> <iphone-simulator-udid>
```

The test harness is compiled only when that script configures
`MASKPAD_BUILD_UI_TESTS`; normal app builds and launches do not enter it.

If compatible user-owned data is already installed in both Simulator
containers, run the separate actual-gameplay semantic gate with:

```sh
scripts/test-ios-gameplay.sh <ipad-simulator-udid> <iphone-simulator-udid>
```

This script refuses to run when a supplied Simulator lacks its local
`Documents/mm.o2r`.

## Generic arm64 device and unsigned IPA

```sh
scripts/configure-ios.sh --device
scripts/build-ios.sh --device
scripts/package-unsigned-ipa.sh
scripts/verify-release.sh artifacts/MaskPad-0.1.0-unsigned.ipa
```

The IPA is intentionally unsigned. Signing requires an Apple development
team and must happen downstream. The packager rejects Simulator products,
provisioning profiles, signing material, ROMs, and the generated `mm.o2r`.

Environment overrides:

- `MASKPAD_BUNDLE_ID`
- `MASKPAD_VERSION`
- `MASKPAD_BUILD_NUMBER`
- `MASKPAD_DEPLOYMENT_TARGET`
- `MASKPAD_HOST_BUILD_DIR`
- `MASKPAD_IOS_BUILD_DIR`

## Patch maintenance

`scripts/apply-patches.sh` is idempotent. It accepts either an unapplied patch
or an exact reverse-check match. `scripts/verify-release.sh` requires every
patch to reverse-apply against the tested checkout and every overlay to match.
This prevents a locally edited disposable source tree from becoming the only
copy of a fix.
