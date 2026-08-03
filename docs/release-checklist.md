# Release checklist

- [x] `scripts/check-repo-safety.sh`
- [x] fresh `scripts/clone-sources.sh`
- [x] `scripts/apply-patches.sh` twice, with the second run reporting already applied
- [x] `scripts/verify-release.sh` reverse-checks all patches and overlays
- [x] clean arm64 Simulator Release build
- [x] clean generic arm64 iPhoneOS Release build
- [x] `scripts/test-ios-ui.sh` passes on representative iPhone and iPad
- [x] when user data is available, `scripts/test-ios-gameplay.sh` passes on
      representative iPhone and iPad
- [x] first-run no-ROM and extraction gates on iPhone and iPad
- [x] full touch/editor/native-HUD matrix on iPhone and iPad
- [x] background/foreground and save persistence
- [x] 1024-pixel app-icon source is opaque, the asset catalog produces the
      expected iPhone/iPad sizes, and both remain legible at home-screen scale
- [ ] physical-device audio, performance, controls, and endurance
- [x] unsigned IPA audit
- [x] approved current-build README captures contain no private local details
- [ ] complete third-party notices and legal review
- [ ] explicit approval for signing or distribution

Binary publishing, signing, TestFlight, App Store submission, and upstream
changes are out of scope until separately authorized. Public source visibility
does not authorize a binary distribution.
