#pragma once

#include "DITECNETMQTT.h"

class Config {
public:
    static Config_t g_config;
    static bool load();
    static void save();
    static void loadDefaults();
    static void printConfig();
    static bool isValid();
    static void incrementCntrIni();
    static void incrementCntrIniMdc();
    static uint16_t getCntrIni();
    static uint16_t getCntrIniMdc();
    static void setCntrIni(uint16_t val);
    static void setCntrIniMdc(uint16_t val);
};

extern Config_t g_config;