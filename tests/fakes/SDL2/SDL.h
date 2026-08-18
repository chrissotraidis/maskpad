#pragma once

#include <stddef.h>
#include <stdint.h>
#include <string.h>

#ifdef __cplusplus
extern "C" {
#endif

typedef int32_t SDL_JoystickID;
typedef int SDL_bool;

enum {
    SDL_FALSE = 0,
    SDL_TRUE = 1,
};

typedef struct SDL_JoystickGUID {
    uint8_t data[16];
} SDL_JoystickGUID;

typedef struct SDL_Joystick SDL_Joystick;
typedef struct SDL_GameController SDL_GameController;

int SDL_NumJoysticks(void);
SDL_JoystickGUID SDL_JoystickGetDeviceGUID(int deviceIndex);
void SDL_JoystickGetGUIDString(SDL_JoystickGUID guid, char* output, int outputSize);
SDL_bool SDL_IsGameController(int deviceIndex);
SDL_JoystickID SDL_JoystickGetDeviceInstanceID(int deviceIndex);
SDL_GameController* SDL_GameControllerOpen(int deviceIndex);
void SDL_GameControllerClose(SDL_GameController* gamepad);
SDL_bool SDL_GameControllerGetAttached(SDL_GameController* gamepad);
SDL_Joystick* SDL_GameControllerGetJoystick(SDL_GameController* gamepad);
SDL_JoystickID SDL_JoystickInstanceID(SDL_Joystick* joystick);
const char* SDL_GameControllerName(SDL_GameController* gamepad);
const char* SDL_GetError(void);

#define SDL_memcmp memcmp

#ifdef __cplusplus
}
#endif
