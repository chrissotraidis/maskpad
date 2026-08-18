#include <algorithm>
#include <cassert>
#include <cstdio>
#include <cstdint>
#include <cstring>
#include <iostream>
#include <memory>
#include <string>
#include <vector>

#include <SDL2/SDL.h>
#include "ship/controller/physicaldevice/ConnectedPhysicalDeviceManager.h"

struct SDL_Joystick {
    int32_t instanceId;
};

struct SDL_GameController {
    SDL_Joystick joystick;
    std::string name;
    bool attached;
    bool heldButton;
    int16_t heldAxis;
};

namespace {
struct FakeDevice {
    int32_t instanceId;
    std::string name;
    bool isGameController = true;
    bool openFails = false;
};

std::vector<FakeDevice> gDevices;
std::vector<SDL_GameController*> gOpenHandles;
int gOpenCount = 0;
int gCloseCount = 0;

void ResetFakeSDL() {
    for (auto* handle : gOpenHandles) {
        delete handle;
    }
    gDevices.clear();
    gOpenHandles.clear();
    gOpenCount = 0;
    gCloseCount = 0;
}

void AddDevice(int32_t instanceId, const char* name) {
    gDevices.push_back({ instanceId, name });
}

void RemoveDeviceWithoutEvent(int32_t instanceId) {
    gDevices.erase(std::remove_if(gDevices.begin(), gDevices.end(), [instanceId](const FakeDevice& device) {
                       return device.instanceId == instanceId;
                   }),
                   gDevices.end());
    for (auto* handle : gOpenHandles) {
        if (handle->joystick.instanceId == instanceId) {
            handle->attached = false;
        }
    }
}

void DetachHandleWithoutRemoval(int32_t instanceId) {
    for (auto* handle : gOpenHandles) {
        if (handle->joystick.instanceId == instanceId) {
            handle->attached = false;
        }
    }
}

bool PortHas(Ship::ConnectedPhysicalDeviceManager& manager, uint8_t port, int32_t instanceId) {
    return manager.GetConnectedSDLGamepadsForPort(port).contains(instanceId);
}

void ExpectOnly(Ship::ConnectedPhysicalDeviceManager& manager, uint8_t port,
                std::initializer_list<int32_t> instanceIds) {
    const auto connected = manager.GetConnectedSDLGamepadsForPort(port);
    assert(connected.size() == instanceIds.size());
    for (const auto instanceId : instanceIds) {
        assert(connected.contains(instanceId));
    }
}
} // namespace

extern "C" {
int SDL_NumJoysticks(void) {
    return static_cast<int>(gDevices.size());
}

SDL_JoystickGUID SDL_JoystickGetDeviceGUID(int deviceIndex) {
    SDL_JoystickGUID guid = {};
    if (deviceIndex >= 0 && deviceIndex < static_cast<int>(gDevices.size())) {
        guid.data[0] = 1;
        std::memcpy(&guid.data[1], &gDevices[deviceIndex].instanceId, sizeof(int32_t));
    }
    return guid;
}

void SDL_JoystickGetGUIDString(SDL_JoystickGUID guid, char* output, int outputSize) {
    std::snprintf(output, static_cast<size_t>(outputSize), "%02x%02x", guid.data[0], guid.data[1]);
}

SDL_bool SDL_IsGameController(int deviceIndex) {
    return deviceIndex >= 0 && deviceIndex < static_cast<int>(gDevices.size()) &&
                   gDevices[deviceIndex].isGameController
               ? SDL_TRUE
               : SDL_FALSE;
}

SDL_JoystickID SDL_JoystickGetDeviceInstanceID(int deviceIndex) {
    return deviceIndex >= 0 && deviceIndex < static_cast<int>(gDevices.size()) ? gDevices[deviceIndex].instanceId : -1;
}

SDL_GameController* SDL_GameControllerOpen(int deviceIndex) {
    if (deviceIndex < 0 || deviceIndex >= static_cast<int>(gDevices.size()) || gDevices[deviceIndex].openFails) {
        return nullptr;
    }
    const auto& device = gDevices[deviceIndex];
    auto* handle = new SDL_GameController{ { device.instanceId }, device.name, true, false, 0 };
    gOpenHandles.push_back(handle);
    gOpenCount++;
    return handle;
}

void SDL_GameControllerClose(SDL_GameController* gamepad) {
    if (gamepad == nullptr) {
        return;
    }
    const auto found = std::find(gOpenHandles.begin(), gOpenHandles.end(), gamepad);
    if (found != gOpenHandles.end()) {
        gOpenHandles.erase(found);
    }
    gCloseCount++;
    delete gamepad;
}

SDL_bool SDL_GameControllerGetAttached(SDL_GameController* gamepad) {
    return gamepad != nullptr && gamepad->attached ? SDL_TRUE : SDL_FALSE;
}

SDL_Joystick* SDL_GameControllerGetJoystick(SDL_GameController* gamepad) {
    return gamepad == nullptr ? nullptr : &gamepad->joystick;
}

SDL_JoystickID SDL_JoystickInstanceID(SDL_Joystick* joystick) {
    return joystick == nullptr ? -1 : joystick->instanceId;
}

const char* SDL_GameControllerName(SDL_GameController* gamepad) {
    return gamepad == nullptr ? nullptr : gamepad->name.c_str();
}

const char* SDL_GetError(void) {
    return "fake SDL error";
}
}

int main() {
    ResetFakeSDL();
    AddDevice(10, "Player One");

    {
        Ship::ConnectedPhysicalDeviceManager manager;
        ExpectOnly(manager, 0, { 10 });
        ExpectOnly(manager, 1, {});

        const auto firstHandle = manager.GetConnectedSDLGamepadsForPort(0).at(10);
        firstHandle->heldButton = true;
        firstHandle->heldAxis = 32767;

        manager.RefreshConnectedSDLGamepads("active-check");
        assert(gOpenCount == 1);
        assert(gCloseCount == 0);
        assert(manager.GetConnectedSDLGamepadsForPort(0).at(10) == firstHandle);

        RemoveDeviceWithoutEvent(10);
        ExpectOnly(manager, 0, {});
        manager.RefreshConnectedSDLGamepads("active-check");
        ExpectOnly(manager, 0, {});
        assert(gCloseCount == 1);

        AddDevice(11, "Returning Player One");
        manager.HandlePhysicalDeviceConnect(0);
        ExpectOnly(manager, 0, { 11 });
        ExpectOnly(manager, 1, {});

        AddDevice(20, "Player Two");
        manager.HandlePhysicalDeviceConnect(1);
        ExpectOnly(manager, 0, { 11 });
        ExpectOnly(manager, 1, { 20 });

        DetachHandleWithoutRemoval(20);
        manager.RefreshConnectedSDLGamepads("foreground");
        ExpectOnly(manager, 0, { 11 });
        ExpectOnly(manager, 1, { 20 });

        manager.UnignoreInstanceIdForPort(2, 20);
        manager.HandlePhysicalDeviceRemap(20);
        assert(PortHas(manager, 1, 20));
        assert(PortHas(manager, 2, 20));
        assert(PortHas(manager, 0, 11));

        RemoveDeviceWithoutEvent(11);
        manager.RefreshConnectedSDLGamepads("foreground");
        ExpectOnly(manager, 0, {});
        ExpectOnly(manager, 1, { 20 });
        ExpectOnly(manager, 2, { 20 });

        AddDevice(30, "Replacement Player One");
        manager.RefreshConnectedSDLGamepads("foreground");
        ExpectOnly(manager, 0, { 30 });
        ExpectOnly(manager, 1, { 20 });
        ExpectOnly(manager, 2, { 20 });
    }

    assert(gOpenHandles.empty());
    ResetFakeSDL();
    std::cout << "MaskPad controller reconciliation tests passed.\n";
    return 0;
}
