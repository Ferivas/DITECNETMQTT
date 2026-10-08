#pragma once

#include "DITECNETMQTT.h"
#include "Telemetry.h"

class DigitalInputs {
public:
    static void init();
    static void poll();
    static void printStatus();
    static uint8_t getInputState(uint8_t index);
    static bool getInputRaw(uint8_t index);
    static void setPolarity(uint8_t index, bool invert);
    static void setEnabled(uint8_t index, bool enable);
    static void setDebounceTime(uint8_t index, uint16_t time_ms);
    static void setDebounceTimeOff(uint8_t index, uint16_t time_ms);
    static void forceUpdate();
    
private:
    static uint8_t _pins[NUM_DIGITAL_INPUTS];
    static uint32_t _last_poll;
    static uint8_t _prev_state[NUM_DIGITAL_INPUTS];
    static void _checkEdge(uint8_t index, uint8_t current_raw);
    static void _generateTelemetry(uint8_t index, bool rising);
};

extern DigitalInputs DigitalInput;