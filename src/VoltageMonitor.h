#pragma once

#include "DITECNETMQTT.h"

class VoltageMonitor {
public:
    static void init();
    static void read();
    static float getVoltage();
    static bool isReady();
    static void setCalibration(float k);
    static void printStatus();
    
private:
    static float _voltage;
    static uint32_t _last_read;
    static uint16_t _sample_sum;
    static uint8_t _sample_count;
    static bool _ready;
};

extern VoltageMonitor VoltageMon;