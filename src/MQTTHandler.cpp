#include "MQTTHandler.h"
#include "Config.h"
#include "EthernetManager.h"
#include <ArduinoJson.h>

PubSubClient* MQTTHandler::_mqtt_client = nullptr;
uint32_t MQTTHandler::_last_reconnect = 0;
bool MQTTHandler::_callback_set = false;
void (*MQTTHandler::_user_callback)(char*, uint8_t*, unsigned int) = nullptr;

void MQTTHandler::_internal_callback(char* topic, uint8_t* payload, unsigned int length) {
    if (_user_callback) {
        _user_callback(topic, payload, length);
    }
}

bool MQTTHandler::init() {
    if (!_mqtt_client) {
        _mqtt_client = new PubSubClient(EthernetManager::getClient());
    }
    _mqtt_client->setServer(Config::g_config.mqtt_server, Config::g_config.mqtt_port);
    _mqtt_client->setCallback(_internal_callback);
    _mqtt_client->setBufferSize(MQTT_BUFFER_SIZE);
    _last_reconnect = 0;
    return reconnect();
}

void MQTTHandler::loop() {
    if (!isConnected()) {
        reconnect();
    }
    _mqtt_client->loop();
}

bool MQTTHandler::isConnected() {
    return _mqtt_client && _mqtt_client->connected();
}

bool MQTTHandler::publishTelemetry(const char* payload) {
    if (!isConnected()) return false;
    return _mqtt_client->publish("v1/devices/me/telemetry", payload);
}

bool MQTTHandler::publishAttribute(const char* key, const char* value) {
    if (!isConnected()) return false;
    
    JsonDocument doc;
    doc[key] = value;
    
    char buffer[256];
    serializeJson(doc, buffer);
    return _mqtt_client->publish("v1/devices/me/attributes", buffer);
}

void MQTTHandler::setCallback(void (*callback)(char*, uint8_t*, unsigned int)) {
    _user_callback = callback;
    _callback_set = true;
}

bool MQTTHandler::reconnect() {
    if (millis() - _last_reconnect < 5000) return false;
    _last_reconnect = millis();
    
    if (isConnected()) return true;
    
    Serial.print(F("MQTT connecting to "));
    Serial.print(Config::g_config.mqtt_server);
    Serial.print(F(":"));
    Serial.println(Config::g_config.mqtt_port);
    
    if (_mqtt_client->connect("DITECNETMQTT", Config::g_config.device_token, nullptr)) {
        Serial.println(F("MQTT connected"));
        _mqtt_client->subscribe("v1/devices/me/rpc/request/+");
        _mqtt_client->subscribe("v1/devices/me/attributes/response/+");
        return true;
    } else {
        Serial.print(F("MQTT failed, rc="));
        Serial.println(_mqtt_client->state());
        return false;
    }
}

void MQTTHandler::printStatus() {
    Serial.print(F("MQTT: "));
    Serial.println(isConnected() ? F("Connected") : F("Disconnected"));
    if (isConnected()) {
        Serial.print(F("Server: "));
        Serial.print(Config::g_config.mqtt_server);
        Serial.print(F(":"));
        Serial.println(Config::g_config.mqtt_port);
    }
}