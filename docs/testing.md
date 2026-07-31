# Verification

## Automated gates

```sh
scripts/check-repo-safety.sh
scripts/verify-release.sh
bash -n scripts/*.sh
```

The safety gate audits publishable paths and Git history for ROMs, derived
game data, build products, packages, signing material, large accidental
files, and likely credentials. The release gate additionally asserts pins,
reverse-applies patches, compares overlays, and can recursively inspect an
app or IPA.

The opt-in, ROM-free Simulator UI suite reconstructs the test target and runs
the same two deterministic tests on every supplied device:

```sh
scripts/test-ios-ui.sh <ipad-simulator-udid> <iphone-simulator-udid>
```

It never enters test mode in a normal build or launch.

When a user-generated `mm.o2r` is already installed in each supplied
Simulator, the separate gameplay suite runs only the actual-engine semantic
test:

```sh
scripts/test-ios-gameplay.sh <ipad-simulator-udid> <iphone-simulator-udid>
```

That script refuses to run without the local archive. Its test-only probe
observes transitions in `PlayState.state.input[0].cur`, after 2S2H has
translated SDL input into the N64 button state consumed by gameplay.

## Simulator acceptance

Run each gate on a representative landscape iPhone and iPad:

1. Fresh install without a ROM shows the Files import instruction and exits
   without producing a partial `mm.o2r`.
2. A supported ROM in Documents is detected, validated, and extracted.
3. The next launch loads both `mm.o2r` and the bundled ROM-free `2ship.o2r`.
4. A, B, Start, all C buttons, D-pad, shoulders, Z latch, and analog movement
   produce the expected in-game behavior and release cleanly.
5. `•••` opens the 2S2H menu and temporarily removes the gameplay overlay.
6. Touch controls can be disabled and restored without a restart.
7. Editor move, resize, hide/show, reset, Done, and safe-area clamping work.
8. Phone and tablet layouts persist independently.
9. Native A/B/C HUD art follows the final touch frames.
10. Home and resume preserve the scene, release held input, pause queued
    audio/rendering in the background, and resume once.

## Evidence observed on 2026-07-30 and 2026-07-31

- clean no-ROM installs on an iPhone 16 Pro and iPad Pro 11-inch (M4),
  iOS 18.5 Simulators, visibly presented complete MaskPad Files guidance;
- dismissing the alert and repeat-launching both device classes presented the
  complete guidance again;
- final arm64 Simulator and generic arm64 iPhoneOS Release bundles passed the
  recursive release audit;
- the unsigned MaskPad IPA passed bundle-identity, archive, game-data,
  signing-material, and arm64 checks;
- on both representative device classes, the layout editor opened from the
  live 2S2H menu and passed selection, hide, Done, relaunch persistence,
  restore/show, and reset;
- phone and tablet layout changes were observed under distinct MaskPad
  preference keys, and resetting the tablet profile cleared it without
  changing the phone profile;
- a persisted hidden A control reopened faded with **Show** selected after the
  editor-state hydration fix, then restored to a full-opacity gameplay target;
- every UIKit touch target's SDL scancode was traced through libultraship's
  translation table to the exact 2S2H N64 button or stick default;
- the opt-in XCUITest suite passed 2/2 tests on both the iPhone 16 Pro and
  iPad Pro 11-inch (M4), iOS 18.5 Simulators, after a repository-scripted
  reconfigure and build;
- that suite exercised press and release on A, B, L, Z, R, Start, all four
  D-pad buttons, all four C buttons, and all four stick directions;
- the same runs verified 70%–150% resize, drag movement, relaunch
  persistence, safe-bound clamping, protected-stick visibility, reset,
  touch controls off/on, Z latch, Home/background cancellation, and
  foreground recovery without a stuck input;
- a test-only visual probe driven by the production native-HUD center and
  scale getters matched the moved/resized A control on both device classes;
- the separate actual-gameplay XCUITest passed on both representative device
  classes and observed engine-consumed press/release transitions for all four
  D-pad directions, all four C directions, L, R, and Z;
- the same engine-state probe verified that holding Z latched the N64 Z bit
  and the next tap released it on both device classes;
- a background-transition regression exposed an over-release of the borrowed
  `CAMetalDrawable` texture; after correcting ownership, the engine-consumption
  test backgrounded and terminated cleanly on both device classes without
  producing a new crash report;
- the replacement 1024×1024 opaque forest-talisman icon compiled through
  Xcode's asset catalog into the expected iPhone `120×120` and iPad `152×152`
  app-icon products, and remained legible in direct 120-pixel and 60-pixel
  downsample checks;
- the final regenerated unsigned IPA has SHA-256
  `e5af976244f73f78ca5a5b24045d1b6a9d4812b0e1cf74f7c4c7d5266412ac7b`;
- arm64 iPad Pro 11-inch (M4), iOS 18.5 Simulator;
- 2S2H 4.0.2 app bundle launched and loaded `2ship.o2r`;
- a supplied ignored user ROM extracted 660 definitions in roughly 8 seconds
  and generated a valid local `mm.o2r`;
- Lost Woods gameplay rendered through SDL Metal;
- Start reached the debug map selector;
- A advanced game interaction, B changed the sword state, and analog drag
  moved Link;
- native A/B/C/C-item HUD art aligned to transparent touch targets;
- Home backgrounding followed by icon resume returned to the same live scene.

This evidence does not substitute for physical-device testing. The ROM-free
suite proves UIKit-to-SDL delivery, while the user-data-gated gameplay suite
proves the maintained mapping reaches the real 2S2H N64 input state on both
representative Simulator classes.

## Physical-device gates

- signed install and in-place update on iPhone and iPad;
- sustained multi-touch feel, safe areas, Pencil/trackpad, and rotation;
- controller connect/reconnect, rumble, and motion;
- speaker, headphones, Bluetooth, interruptions, and route changes;
- performance, memory pressure, suspend/resume endurance, and thermals;
- development-team provisioning and any distribution workflow.
