#pragma once

#include "DITECNETMQTT.h"
#include <PubSubClient.h>
#include <Client.h>

class MQTTHandler {
public:
    static bool init();
    static void loop();
    static bool isConnected();
    static bool publishTelemetry(const char* payload);
    static bool publishAttribute(const char* key, const char* value);
    static void setCallback(void (*callback)(char*, uint8_t*, unsigned int));
    static bool reconnect();
    static void printStatus();
    
private:
    static PubSubClient* _mqtt_client;
    static uint32_t _last_reconnect;
    static bool _callback_set;
    static void (*_user_callback)(char*, uint8_t*, unsigned int);
    static void _internal_callback(char* topic, uint8_t* payload, unsigned int length);
};

extern MQTTHandler MqttHandler;