# MaskPad iOS and iPadOS implementation plan

Status: active living plan
Reference: read-only `ref/harkinianpad` at
`4db21e4be0f0be52948438de5d8c755d191897ae`
Last updated: 2026-07-30

## Goal and evidence rule

MaskPad is the Majora's Mask counterpart to HarkinianPad: a native,
ROM-free iOS/iPadOS application built from pinned official 2 Ship 2
Harkinian (2S2H) sources. A milestone is complete only after its stated
command and runtime gate passes. Simulator, generic-device, physical-device,
signing, and game-data evidence are recorded separately.

HarkinianPad is an authoritative read-only design and implementation
reference. MaskPad owns all scripts, documentation, assets, and maintained
patches in this repository. Upstream checkouts are disposable, fetch-only
inputs with disabled push URLs.

## Architecture and pinned dependencies

2S2H is a native game application layered on libultraship. Libultraship owns
the cross-platform window, Metal/SDL rendering path, audio, controller input,
resource management, configuration, and platform services. The 2S2H tree
owns the Majora's Mask game port, archive generation/extraction integration,
game-specific menus, settings, and input semantics. Its exact submodule graph
and gitlinks will be recorded here immediately after the official stable
source is reconstructed.

The baseline is the verified official 2S2H 4.0.2 release rather than a moving
development branch. The source and every recursive gitlink were resolved from
Git, checked out, asserted, built, and launched.

| Input | Official repository | Pinned revision | Status |
|---|---|---|---|
| 2 Ship 2 Harkinian | `https://github.com/HarbourMasters/2ship2harkinian.git` | `acfd617302ebb74e63f26f0049b53400a644c8e8` | verified |
| libultraship | exact 2S2H gitlink | `b2dd85ca393225afb0c949035e0eabf87751ff89` | verified |
| ZAPDTR | exact 2S2H gitlink | `684f21a475dcfeee89938ae1f4afc42768a3e7ef` | verified |
| OTRExporter | exact 2S2H gitlink | `32e088e28c8cdd055d4bb8f3f219d33ad37963f3` | verified |

`scripts/clone-sources.sh` asserts every revision and disables every push URL.
Fetched iOS dependencies are pinned in the maintained CMake patches and
overlay rather than resolved from moving branches.

## HarkinianPad versus MaskPad

| Concern | HarkinianPad / Shipwright | MaskPad / 2S2H action |
|---|---|---|
| Native shell | Patched Shipwright iOS app target | Port structure, then adapt target names and 2S2H entry points |
| Engine | Shipwright-pinned libultraship | Reuse iOS work only where the 2S2H gitlink is compatible |
| Port archive | ROM-free `soh.o2r` plus local `oot.o2r` | Discover and generate 2S2H's ROM-free archive; locally generate its Majora archive |
| First run | Files-visible Ocarina ROM import/rescan | Majora ROM validation/import/rescan with Majora-specific instructions |
| Inputs | Shipwright keyboard/config/menu semantics | Verify actual 2S2H semantic input path before translating controls |
| Touch UI | Accepted phone/tablet controller and editor | Copy implementation and geometry; change namespaces and game hooks only |
| Native HUD | OoT HUD symbols and frames | Adapt symbols/hooks to Majora's Mask HUD while preserving touch frames |
| Branding | HarkinianPad identity/assets | MaskPad display name, bundle identity, icon, metadata, and copy |

## Component disposition

Copy directly where source compatibility allows:

- safety, packaging, source-pin, patch-replay, and build-script structure;
- app lifecycle and foreground/background cancellation policy;
- landscape-only native shell, safe-area rules, UIKit overlay architecture;
- phone/tablet default geometry and visual hierarchy;
- layout editor interactions, size limits, clamping, protected controls;
- persistent menu affordance and legacy fixed-controls fallback;
- validation categories and evidence separation.

Adapt:

- CMake target paths and executable/bundle names;
- application delegates, engine start/stop hooks, and menu integration;
- archive generation, ROM compatibility, Files-visible instructions, and
  archive discovery;
- input injection and held-input cancellation to 2S2H semantics;
- native HUD hooks and Majora artwork;
- preference namespaces:
  `MaskPad.TouchLayout.phone-v1` and
  `MaskPad.TouchLayout.tablet-v1`;
- user-facing strings, bundle metadata, icon, versioning, package names, and
  rights notices.

Replace:

- Shipwright/Ocarina-specific extraction and supported-ROM assumptions;
- OoT archive names, game hooks, and HUD symbols that do not exist in 2S2H;
- any patch hunks that target source files absent from the pinned 2S2H tree.

## Required platform work

- **Build:** configure arm64 iPhoneOS and `SIMULATORARM64` Xcode projects,
  keep optional JIT/dynamic scripting disabled, link all targets statically,
  and expose unsigned generic-device plus Simulator workflows.
- **Rendering:** retain libultraship's supported SDL Metal path, connect
  drawable resizing to rotation/window events, and prevent render work while
  backgrounded.
- **Audio:** use the supported libultraship/SDL iOS backend, suspend/resume
  safely across backgrounding and interruption, and reserve real-route
  acceptance for hardware.
- **Lifecycle:** cancel every held touch input before menus, layout editing,
  overlay rebuilds, disabling controls, and backgrounding; recover without
  duplicate engine startup.
- **Filesystem:** enable Files-visible Documents storage, preserve saves
  across launches and in-place updates, and keep all user-owned data local.
- **Input:** preserve keyboard, pointing-device, SDL game-controller, and
  touch paths; verify each N64 action at the engine's real input boundary.
- **Extraction:** accept only supported user-selected Majora ROMs, generate
  the required archive locally, show understandable progress/errors, and
  rescan without rebuilding the app.
- **Packaging:** assemble a ROM-free `.app`/IPA, include rights and discovered
  third-party licenses, reject Simulator products for device packaging, and
  reject ROMs, derived game archives, stale signatures, and provisioning data.

## Touch-control parity map

| HarkinianPad behavior | MaskPad acceptance |
|---|---|
| Landscape phone/tablet defaults | Exact accepted normalized geometry and size rules |
| Stick plus separate D-pad | Present, independently positioned, correct Majora actions |
| A, B, L, Z, R, Start, four C buttons | All present with verified press/release semantics |
| Persistent `•••` | Always menu-capable; not editable or hideable |
| Transparent UIKit targets over native HUD | Preserved where the Majora HUD can own presentation |
| Touch Controls toggle | Live hide/show without restart or stuck input |
| Customize editor | Select, move, resize, hide/show, Reset, Done |
| Size limits | 70% through 150% |
| Separate persistence | Normalized phone/tablet layouts in MaskPad namespaces |
| Safe-area clamping | Every editable control remains reachable |
| Protected stick | Movable/resizable but never hideable |
| Legacy fallback | Fixed controller remains independently selectable |
| Z hold/latch | Same visual state, haptic feedback, and safe release |
| Menu/editor/background transitions | Cancel held inputs before state changes |
| Native HUD following | HUD elements use final customized frames and hide appropriately |

Any divergence requires a minimal technical justification in this document.

## Milestones and acceptance criteria

1. **Plan and safety**
   - This plan and `docs/remaining-work.md` exist.
   - `scripts/check-repo-safety.sh` passes before source download.
2. **Pinned reconstruction**
   - One command clones official source, disables push URLs, checks out exact
     revisions, initializes exact submodules, and asserts all SHAs.
3. **Patch baseline**
   - MaskPad-owned patches apply cleanly and rerun idempotently.
   - Reverse checks prove patch files match the tested source state.
4. **Native shell and extraction**
   - ROM-free Simulator app launches to an accurate first-run or ready state.
   - Documents is Files-visible; rescan and error paths work without a ROM.
5. **Touch parity**
   - Both device classes match HarkinianPad geometry and editor behavior.
   - Every target emits verified 2S2H press/release semantics.
6. **Build proof**
   - Clean arm64 Simulator and generic arm64 iPhoneOS Release builds pass.
7. **Runtime proof**
   - Representative iPhone and iPad Simulator install/launch, lifecycle,
     landscape, menu, touch, editor, and persistence gates pass.
8. **Package and handoff**
   - App/IPA audits pass and documentation reflects observed evidence only.

## Evidence snapshot — 2026-07-30

- Repository safety passed before source reconstruction.
- Official 2S2H 4.0.2 and all three recursive gitlinks were verified.
- A fresh disposable reconstruction replayed every maintained patch and
  synchronized overlay, with forward and reverse checks passing.
- The ROM-free `2ship.o2r` was generated without a ROM and validated as ZIP.
- Final arm64 Simulator and generic arm64 iPhoneOS Release apps built and
  passed the recursive release audit.
- Clean installs on an iPhone 16 Pro and iPad Pro 11-inch (M4), both iOS 18.5
  Simulators, visibly showed the no-ROM Files guidance and stayed alive while
  the alert was presented.
- The alert dismissed normally on both device classes, and a second clean
  launch presented the complete guidance again.
- Files-visible Documents accepted the ignored user ROM; the first launch
  extracted 660 definitions in roughly 8 seconds and generated `mm.o2r`.
- The next launch loaded the local `mm.o2r` and bundled `2ship.o2r`.
- Visible Lost Woods gameplay verified Metal rendering, aligned native
  A/B/C HUD touch targets, A/B actions, Start, and analog movement.
- Home followed by icon resume returned to the same live gameplay scene after
  background render/audio/input handling.
- On both device classes, the editor passed selection, hide, Done, relaunch
  persistence, show, and reset with independent phone/tablet preference keys.
- A startup ordering bug in the editor was fixed so persisted hidden state
  immediately selects **Show** rather than **Hide**.
- Every touch target was traced from its UIKit SDL scancode through
  libultraship translation to 2S2H's N64 button/stick defaults.
- The opt-in XCUITest suite passed 2/2 tests on both representative Simulator
  classes after a repository-scripted reconfigure/build. It covers every
  virtual button and stick direction, editor move/resize/clamp/persistence,
  protected-stick behavior, touch off/on, Z latch, lifecycle cancellation,
  stuck-input prevention, and production native-HUD center/scale follow.
- A separate user-data-gated XCUITest observed
  `PlayState.state.input[0].cur` and passed real engine-consumption checks for
  all D-pad and C directions, L, R, and momentary/latched Z on both
  representative Simulator classes.
- The unsigned `MaskPad-0.1.0-unsigned.ipa` passed recursive ROM, generated
  game-data, signing-material, bundle-identity, archive, and architecture
  checks. The final package SHA-256 is
  `af2280cb89d5a123130e1b097960bd4bb4cdedce8c04ec0fcbd290c302c56275`.

All Simulator implementation gates are closed. Physical-device, signing,
legal-review, and distribution gates remain tracked in
`docs/remaining-work.md`.

## Simulator test matrix

| Gate | Representative iPhone | Representative iPad |
|---|---:|---:|
| Clean install and first launch | required | required |
| Repeat launch/process survival | required | required |
| Landscape enforcement and resize | required | required |
| Foreground/background recovery | required | required |
| First-run instructions/rescan | required | required |
| Every touch target press/release | required | required |
| Menu hide/restore and toggle | required | required |
| Editor move/resize/hide/show/reset/save | required | required |
| Stick/menu protection and safe-area clamp | required | required |
| Independent phone/tablet persistence | cross-check | cross-check |
| Native HUD follows final frames | required when game data is available | required when game data is available |
| Extraction/gameplay/save | user-owned ROM gate | user-owned ROM gate |

Process survival alone is not visible UI acceptance. Captures and concise logs
remain local unless publication is separately approved.

## Repository and game-data safety

- ROMs, derived playable archives, extracted assets, build products, IPAs,
  provisioning profiles, private keys, and local evidence are ignored.
- The compile and CI workflow never read a ROM.
- `ref/harkinianpad` stays ignored and read-only.
- Safety runs before and after builds and audits current paths plus Git history.
- Package inspection recursively rejects game data and unexpected signing.
- No upstream checkout has a working push URL.
- No game screenshots or private paths are committed without approval.

## Risks, questions, and physical-device gates

- 2S2H may pin a libultraship revision that requires rebasing HarkinianPad's
  maintained engine patch rather than applying it directly.
- Game/archive generation targets and supported Majora ROM variants may differ
  materially from Shipwright and must be discovered from source.
- 2S2H input configuration symbols and menu hooks must be verified rather than
  inferred from its desktop defaults.
- Native HUD ownership may differ; UIKit fallback is acceptable only where a
  native-HUD hook is unavailable and the divergence is documented.
- Physical iPhone/iPad installation, touch feel, controller reconnect, rumble,
  motion, audio routes/interruptions, performance, thermals, signing, and
  distribution remain hardware or credential gates until directly tested.
- A compatible user-owned ROM exists only in ignored local storage and was
  used for Simulator extraction/gameplay proof. It must never enter Git or a
  release package.
