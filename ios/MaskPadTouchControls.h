#pragma once

#ifdef __cplusplus
extern "C" {
#endif

int MaskPad_TouchControlsAvailable(void);
void MaskPad_SetTouchControlsEnabled(int enabled);
void MaskPad_SetCustomizableTouchControlsEnabled(int enabled);
void MaskPad_SetTouchControlsOpacity(float opacity);
void MaskPad_BeginTouchLayoutEditing(void);
void MaskPad_RunUITestMode(void);
void MaskPad_SetTouchControlsMenuVisible(int visible);
void MaskPad_ShowMissingRomMessage(void);
#if defined(MASKPAD_UI_TEST_HARNESS)
void MaskPad_ReportConsumedInput(unsigned int buttons, int stickX, int stickY);
#endif

enum {
    MASKPAD_HUD_BUTTON_A = 0,
    MASKPAD_HUD_BUTTON_B,
    MASKPAD_HUD_BUTTON_C_UP,
    MASKPAD_HUD_BUTTON_C_DOWN,
    MASKPAD_HUD_BUTTON_C_LEFT,
    MASKPAD_HUD_BUTTON_C_RIGHT,
    MASKPAD_HUD_BUTTON_COUNT,
};

void MaskPad_SetNativeHudTouchEnabled(int enabled);
void MaskPad_SetNativeHudTouchGameplayActive(int active);
int MaskPad_GetNativeHudButtonCenter(int button, float aspectRatio, float* x, float* y);
float MaskPad_GetNativeHudButtonScale(int button, float aspectRatio);
int MaskPad_GetNativeHudTouchAlpha(int alpha);

#ifdef __cplusplus
}
#endif
