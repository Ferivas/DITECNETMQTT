#pragma once

#include "DITECNETMQTT.h"

class LedStatus {
public:
    static void init();
    static void update();
    static void setPattern(uint8_t pattern);
    static uint8_t getPattern();
    static void printStatus();
    
private:
    static const uint32_t _patterns[17];
    static uint8_t _current_pattern;
    static uint8_t _window;
    static uint32_t _last_update;
    static void _setLed(bool on);
};

extern LedStatus LedMgr;