#pragma once

// Touch-control visibility decisions shared by the overlay, the settings menu
// and MaskPad's native tests. libultraship stays the controller authority:
// callers pass what it has assigned to player 1, whose input the touch
// controller provides through the default keyboard mappings.
namespace MaskPad {

struct GamepadProfile {
    bool leftStick = false;
    bool faceButtons = false; // A, B, X and Y
    bool start = false;
};

// A remote or menu-only profile cannot play the game, so it never hides the
// complete touch controller.
constexpr bool IsGameplayGamepad(const GamepadProfile& profile) {
    return profile.leftStick && profile.faceButtons && profile.start;
}

struct TouchPreferences {
    bool touchControls = true;          // "Touch Controls"; off is the deliberate manual hide
    bool autoHideWithController = true; // "Auto-hide Touch Controls with Controller"
};

// "Show Touch Controls" recovers from both kinds of hiding and keeps the
// controls visible until the user turns auto-hide back on.
constexpr TouchPreferences ShowTouchControls(TouchPreferences) {
    return { true, false };
}

constexpr bool TouchGameplayControlsVisible(const TouchPreferences& preferences, bool playerOneHasGameplayGamepad) {
    return preferences.touchControls && !(preferences.autoHideWithController && playerOneHasGameplayGamepad);
}

} // namespace MaskPad
