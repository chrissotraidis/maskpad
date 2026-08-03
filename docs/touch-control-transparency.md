# Touch-control transparency

MaskPad can reduce the visual opacity of its touch controller without changing
the size, position, or hit testing of any control.

- **Touch Control Transparency** is off by default, preserving the original
  appearance for existing and clean installations.
- Enabling it reveals a persisted **Touch Control Opacity** slider from 25% to
  100%, with a 50% default.
- UIKit controls, the permanent menu button, and native gameplay A/B/C artwork
  use the selected opacity.
- The layout editor temporarily displays visible controls at full opacity so
  selection, hiding, moving, and resizing remain clear.
- Legacy Fixed Touch Controls use the same opacity setting.

The Simulator release gate covers both slider extremes, persistence after
relaunch, unchanged hit targets, full-opacity layout editing, native HUD
artwork, and legacy-layout behavior. Repeat that matrix on physical iPad
before closing the remaining hardware gate or authorizing binary distribution.
