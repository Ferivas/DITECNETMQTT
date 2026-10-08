#pragma once

#include "DITECNETMQTT.h"
#include <OneWire.h>
#include <DallasTemperature.h>

class TemperatureSensor {
public:
    static void init();
    static void read();
    static float getTemperature();
    static bool isValid();
    static void printStatus();
    
private:
    static OneWire _oneWire;
    static DallasTemperature _sensors;
    static float _last_temp;
    static uint32_t _last_read;
    static bool _initialized;
    static uint8_t _crc_errors;
};

extern TemperatureSensor TempSensor;