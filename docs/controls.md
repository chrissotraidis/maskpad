# Touch controls

MaskPad keeps the engine's keyboard, pointer, and SDL game-controller paths.
The UIKit overlay adds a touch path by emitting the same semantic bindings
used by 2S2H.

| Touch target | Engine binding | Meaning |
|---|---|---|
| Stick | W/A/S/D | N64 analog movement |
| A | X | A action |
| B | C | B action |
| L | E | L trigger |
| Z | Z | Z trigger; hold to latch in customizable mode |
| R | R | R trigger |
| Start | Space | Start |
| D-pad | T/F/G/H | N64 D-pad |
| C buttons | Arrow keys | N64 C directions |
| `•••` | Escape | 2S2H menu |

Short taps remain pressed for at least 50 ms so 2S2H observes both the press
and release even when UIKit receives them within one engine frame. Opening the
menu, entering the editor, disabling controls, rebuilding the overlay, or
backgrounding the app releases every held input.

The maintained mapping was verified twice: the ROM-free suite checks every
UIKit-to-SDL transition, and the user-data-gated gameplay suite observes the
real 2S2H N64 input state for the D-pad, C buttons, L, R, and Z latch on both
representative iPhone and iPad Simulators.

## Custom layout

Open `•••`, then **Settings → Controls → Customize Touch Layout**.

- Tap a control to select it.
- Drag it to move it.
- Use **Size** for 70–150% scaling.
- Use **Hide/Show** for optional controls.
- **Reset** restores the current device-class default.
- **Done** saves normalized positions and sizes.

The stick cannot be hidden. The persistent `•••` menu affordance is outside
the editable layout. Layouts are stored separately under the MaskPad phone
and tablet namespaces, and every control is clamped to the safe area.

The **Legacy Fixed Touch Controls** option keeps the fixed UIKit presentation
and disables customization, Z latching, and native HUD artwork alignment.

Enable **Touch Control Transparency** to reveal a persisted 25%–100% opacity
slider. Opacity changes only presentation: control frames, gesture recognizers,
bindings, and saved layouts remain unchanged. The layout editor temporarily
shows visible controls at full opacity.

## Native HUD behavior

During gameplay the transparent A/B/C touch targets remain interactive while
Majora's Mask draws its own button backgrounds, item icons, ammo, and action
label at their customized centers. UIKit artwork returns in menus, the layout
editor, and non-gameplay states.
