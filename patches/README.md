# Maintained source patches

Apply in this order with `scripts/apply-patches.sh`:

1. `2ship-ios.patch` at the pinned 2S2H root;
2. `libultraship-ios.patch` in its pinned submodule. It includes SDL 2.32.10
   UIKit scene startup and scene orientation, which apps built with the iOS 27
   SDK need in order to open (the same backport as StarshipPad and SpaghettiPad).
   `libultraship-uikit-scenes.patch` adds only that part to a checkout patched
   before it. The nested SDL patch matches chrissotraidis/SDL
   `pads/2.32.10-uikit-scenes` (090b0c5a), whose window follows the scene that
   started SDL; `libultraship-sdl2-window-ownership.patch` upgrades a checkout
   patched before that fix;
3. `zapdtr-ios.patch` in its pinned submodule;
4. copy `port/CMake/ios.cmake` and `ios/` as new source overlays.

The release verifier requires every patch to reverse-apply against the tested
checkout and every overlay file to match byte-for-byte.
