# Release checklist

- [ ] `scripts/check-repo-safety.sh`
- [ ] fresh `scripts/clone-sources.sh`
- [ ] `scripts/apply-patches.sh` twice, with the second run reporting applied
- [ ] `scripts/verify-release.sh` reverse-checks all patches and overlays
- [ ] clean arm64 Simulator Release build
- [ ] clean generic arm64 iPhoneOS Release build
- [ ] `scripts/test-ios-ui.sh` passes on representative iPhone and iPad
- [ ] when user data is available, `scripts/test-ios-gameplay.sh` passes on
      representative iPhone and iPad
- [ ] first-run no-ROM and extraction gates on iPhone and iPad
- [ ] full touch/editor/native-HUD matrix on iPhone and iPad
- [ ] background/foreground and save persistence
- [ ] 1024-pixel app-icon source is opaque, the asset catalog produces the
      expected iPhone/iPad sizes, and both remain legible at home-screen scale
- [ ] physical-device audio, performance, controls, and endurance
- [ ] unsigned IPA audit
- [ ] complete third-party notices and legal review
- [ ] explicit approval for signing or distribution

Publishing, signing, TestFlight, App Store submission, and upstream changes
are out of scope until separately authorized.
