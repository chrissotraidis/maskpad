# Contributing to MaskPad

Thanks for helping improve the iPhone and iPad port.

## Before opening an issue

- Search existing issues first.
- Reproduce the problem on the latest `main` build when practical.
- Include the MaskPad commit, Apple device model, OS version, installation
  method, input method, and exact reproduction steps.
- Attach logs or screenshots only after checking that they contain no
  personal paths, signing information, ROM data, or generated game archives.
- Never request, attach, or link to copyrighted game data.

The structured bug-report template collects the details needed to distinguish
Simulator, physical-device, audio, controller, lifecycle, and signing issues.

## Making a change

1. Run `scripts/check-repo-safety.sh`.
2. Keep changes in this repository. `sources/` contains disposable,
   fetch-only upstream inputs.
3. Edit maintained patches or MaskPad-owned files instead of committing
   generated upstream trees.
4. Build the relevant target:

   ```sh
   scripts/configure-ios.sh --simulator
   scripts/build-ios.sh --simulator
   # or
   scripts/configure-ios.sh --device
   scripts/build-ios.sh --device
   ```

5. Run the relevant tests and release audit.
6. Update documentation whenever observed behavior or a release gate changes.

Pull requests should stay focused and explain the user-visible impact, exact
validation performed, and any physical-device checks that remain open.

## Game-data boundary

ROMs, `mm.o2r`, `.otr`, extracted Nintendo assets, signed applications,
provisioning profiles, and IPAs must never enter Git history. Keep legal local
game data under ignored `ref/` or in the installed app's Documents container.

## Licensing

Each upstream component retains its own license and copyright. MaskPad
currently has no top-level license grant; contributing does not change that
status. See [`RIGHTS_AND_LICENSES.md`](RIGHTS_AND_LICENSES.md).
