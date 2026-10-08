#pragma once

#include "DITECNETMQTT.h"
#include <SPI.h>
#include <Client.h>

class EthernetClient;

class EthernetManager {
public:
    static bool init();
    static bool isConnected();
    static void maintain();
    static void printStatus();
    static Client& getClient();
    static void reset();
    
private:
    static bool _initialized;
    static uint32_t _last_maintain;
};

extern EthernetManager EthManager;