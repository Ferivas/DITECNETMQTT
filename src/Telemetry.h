#pragma once

#include "DITECNETMQTT.h"
#include <ArduinoJson.h>

class Telemetry {
public:
    static void init();
    static bool enqueue(const TelemetryData_t& data);
    static bool dequeue(TelemetryData_t& data);
    static bool isEmpty();
    static uint8_t getCount();
    static void sendNext();
    static void sendPeriodic();
    static void buildJson(const TelemetryData_t& data, char* buffer, size_t size);
    static void printBuffer();
    
private:
    static TelemetryBuffer_t _buffer;
    static uint32_t _last_periodic[4];
    static bool _is_full();
};

extern Telemetry TelemetryMgr;