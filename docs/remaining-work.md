# Remaining work

This file is the live evidence ledger for MaskPad. Items leave the list only
after their exact gate is observed.

## Completed

- Read the goal objective and the required HarkinianPad reference categories.
- Located the read-only reference at `ref/harkinianpad`.
- Confirmed the MaskPad checkout began without commits or implementation.
- Added MaskPad game-data, build-product, signing-material, source, and
  reference exclusions.
- Added the first repository-safety gate.
- Created the living implementation plan and touch parity contract.
- Confirmed local Xcode 26.6, Apple Silicon, CMake, Ninja, and Homebrew.
- Verified official 2S2H 4.0.2 and exact libultraship, ZAPDTR, and OTRExporter
  gitlinks; disabled all upstream push URLs.
- Added reproducible clone, patch, port-archive, Simulator/device configure,
  build, unsigned-IPA, and release-audit scripts.
- Generated and validated the ROM-free `2ship.o2r`.
- Ported the native landscape app bundle, Files-visible Documents, automatic
  ROM discovery/extraction, Metal rendering, mobile GUI, and input mappings.
- Ported phone/tablet touch controls, persistent menu, Z latch, layout editor,
  device-class persistence, safe-area clamping, and native Majora HUD hooks.
- Added explicit background configuration save, audio pause/queue clear,
  render suspension, foreground resume, and held-touch cancellation.
- Passed an arm64 iPad Simulator Release build and visible launch.
- Used the ignored user ROM to extract 660 definitions, generate `mm.o2r`,
  load both archives, and render playable Lost Woods.
- Verified Start, A/B actions, analog movement, native A/B/C HUD alignment,
  and Home/background/icon-resume behavior in the live app.
- Added original MaskPad icon/metadata plus building, controls, testing,
  rights, and release documentation.
- Renamed the GitHub repository to `chrissotraidis/maskpad`, updated the local
  origin, and removed the former project name from publishable source, docs,
  scripts, patches, package names, and assets.
- Reconstructed the pinned source tree from scratch, replayed all maintained
  patches, synchronized overlays, and passed forward/reverse patch checks.
- Passed final arm64 Simulator and generic arm64 iPhoneOS Release builds plus
  recursive `.app` audits.
- Clean-installed the final ROM-free app on an iPhone 16 Pro and iPad Pro
  11-inch (M4), iOS 18.5 Simulators, and visibly verified the complete MaskPad
  Files import alert on both.
- Dismissed the no-ROM alert on both device classes and verified that a second
  launch cleanly presented the complete guidance again.
- Packaged `MaskPad-0.1.0-unsigned.ipa` and passed recursive bundle identity,
  archive, arm64, ROM/generated-game-data, and signing-material checks.
- Exercised the layout editor on both device classes: selection, hide, Done,
  relaunch persistence, show, reset, and separate
  `MaskPad.TouchLayout.phone-v1` / `tablet-v1` storage all passed.
- Fixed editor startup so a persisted hidden selection immediately presents
  the correct **Show** action, then rebuilt and re-audited both app targets.
- Traced every touch target from its UIKit SDL scancode through libultraship's
  SDL-to-LUS translation table to 2S2H's exact N64 button/stick defaults.
- Regenerated and audited the final unsigned IPA after fixing relative output
  path handling in the packaging script.
- Added an opt-in XCUITest target and repository script, then passed both
  tests on iPhone 16 Pro and iPad Pro 11-inch (M4), iOS 18.5 Simulators.
- Verified gesture movement, 70%–150% resize, persistence, safe-bound clamp,
  protected-stick visibility, reset, touch controls off/on, Z latch,
  Home/background cancellation, foreground recovery, and stuck-input
  prevention on both representative device classes.
- Verified press/release delivery for every virtual button and all four stick
  directions on both device classes.
- Verified that the production native-HUD center and scale getters follow a
  moved/resized A control on both device classes.
- Added a separate user-data-gated gameplay test that observes the real
  `PlayState.state.input[0].cur` N64 input state after 2S2H translation.
- Passed actual engine-consumption checks for all four D-pad directions, all
  four C directions, L, R, and momentary/latched Z on both the iPhone 16 Pro
  and iPad Pro 11-inch (M4), iOS 18.5 Simulators.
- Re-ran the two ROM-free UI/editor tests on both device classes after adding
  the gameplay probe; all four executions passed.
- Fixed the Metal screen-framebuffer ownership bug that over-released a
  `CAMetalDrawable` texture during background cleanup, then passed the
  engine-consumption, background, and termination regression on both
  representative device classes with no new crash reports.
- Rebuilt the generic iPhoneOS app and unsigned IPA after the final app-icon
  selection; the audited package SHA-256 is
  `af2280cb89d5a123130e1b097960bd4bb4cdedce8c04ec0fcbd290c302c56275`.
- Replaced the README screenshot placeholders with approved current-build
  iPad Simulator gameplay, touch-controller, and Controls captures.
- Added a persisted 25%–100% touch-opacity control without changing hit
  targets, bindings, layout geometry, or the full-opacity layout editor.
- Reused Metal depth-stencil states and corrected the iOS MSAA CVar read, then
  passed the complete three-test iPad Simulator regression suite.
- Stopped iOS gameplay simulation while SDL reports that presentation is
  inactive, while continuing to pump lifecycle events so foreground recovery
  remains responsive.
- Replaced the README gallery with five maintainer-approved physical-iPad
  captures and selected the sword-combat image as the hero.
- Published the audited, ROM-free `MaskPad-0.1.0-unsigned.ipa` and its SHA-256
  file in the `v0.1.0` GitHub Release with explicit maintainer approval.

All in-scope Simulator implementation gates are closed.

## User-owned data evidence

A compatible user-owned ROM in ignored `ref/` storage was used only for local
Simulator extraction and gameplay validation. The generated `mm.o2r` remains
inside ignored Simulator Documents. The separate no-ROM clean-install visual
gate now passes on representative iPhone and iPad Simulators.

## Physical-device, signing, and distribution gates

The app has been signed, installed, launched, updated in place, and played on
a 12.9-inch iPad Pro (6th generation) running iPadOS 26.5.2, with its local ROM
and save data preserved. Touch controls and speaker audio work there. Reported
area-load frame losses and occasional music skips remain unresolved.

- Signed installation and in-place update on physical iPhone.
- Extended physical touch ergonomics, Pencil/trackpad behavior, controller
  connect/reconnect, rumble, and motion.
- Headphone, Bluetooth, interruption, and route-change audio.
- Performance, memory pressure, thermals, and suspend/resume endurance.
- Physical screenshot-editor pause/resume acceptance with the inactive-loop
  fix.
- Apple development-team provisioning, TestFlight/App Store distribution,
  paid/commercial distribution review, and upstream licensing clarification.
