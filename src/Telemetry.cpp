#include "Telemetry.h"
#include "Config.h"
#include "MQTTHandler.h"
#include "TemperatureSensor.h"
#include "VoltageMonitor.h"

TelemetryBuffer_t Telemetry::_buffer = {{0}, 0, 0, 0};
uint32_t Telemetry::_last_periodic[4] = {0, 0, 0, 0};

void Telemetry::init() {
    _buffer.head = 0;
    _buffer.tail = 0;
    _buffer.count = 0;
    for (int i = 0; i < 4; i++) {
        _last_periodic[i] = millis();
    }
    Serial.println(F("Telemetry initialized"));
}

bool Telemetry::enqueue(const TelemetryData_t& data) {
    if (_is_full()) {
        _buffer.tail = (_buffer.tail + 1) % TELEMETRY_BUFFER_SIZE;
        _buffer.count--;
    }
    
    _buffer.data[_buffer.head] = data;
    _buffer.head = (_buffer.head + 1) % TELEMETRY_BUFFER_SIZE;
    _buffer.count++;
    return true;
}

bool Telemetry::dequeue(TelemetryData_t& data) {
    if (_buffer.count == 0) return false;
    
    data = _buffer.data[_buffer.tail];
    _buffer.tail = (_buffer.tail + 1) % TELEMETRY_BUFFER_SIZE;
    _buffer.count--;
    return true;
}

bool Telemetry::isEmpty() {
    return _buffer.count == 0;
}

uint8_t Telemetry::getCount() {
    return _buffer.count;
}

bool Telemetry::_is_full() {
    return _buffer.count >= TELEMETRY_BUFFER_SIZE;
}

void Telemetry::sendNext() {
    TelemetryData_t data;
    if (dequeue(data)) {
        char json[MQTT_BUFFER_SIZE];
        buildJson(data, json, MQTT_BUFFER_SIZE);
        if (MQTTHandler::publishTelemetry(json)) {
            Serial.print(F("Telemetry sent: "));
            Serial.println(json);
        } else {
            Serial.println(F("Telemetry send failed, requeue"));
            enqueue(data);
        }
    }
}

void Telemetry::sendPeriodic() {
    uint32_t now = millis() / 1000;
    
    for (int i = 0; i < 4; i++) {
        if (Config::g_config.autoval[i] > 0) {
            uint32_t period = Config::g_config.autoval[i];
            uint32_t offset = Config::g_config.offset[i];
            
            if ((now + offset) % period < (now - _last_periodic[i] + offset) % period) {
                _last_periodic[i] = now;
                
                TelemetryData_t data = {};
                data.has_timestamp = false;
                
                for (uint8_t j = 0; j < NUM_DIGITAL_INPUTS; j++) {
                    if (Config::g_config.edhab & (1 << j)) {
                        uint8_t val = g_di_state[j].last_raw;
                        switch (j) {
                            case 0: data.pt1 = val; break;
                            case 1: data.pt2 = val; break;
                            case 2: data.ac1 = val; break;
                            case 3: data.tvs = val; break;
                        }
                    }
                }
                
                data.pwr = VoltageMonitor::getVoltage();
                data.temp = TemperatureSensor::getTemperature();
                data.cini = Config::getCntrIni();
                data.cinimdc = Config::getCntrIniMdc();
                
                enqueue(data);
            }
        }
    }
}

void Telemetry::buildJson(const TelemetryData_t& data, char* buffer, size_t size) {
    StaticJsonDocument<512> doc;
    JsonObject values = doc.createNestedObject("values");
    
    values["pt1"] = data.pt1;
    values["pt2"] = data.pt2;
    values["ac1"] = data.ac1;
    values["tvs"] = data.tvs;
    values["pwr"] = data.pwr;
    values["t1"] = data.temp;
    values["cini"] = data.cini;
    values["cinimdc"] = data.cinimdc;
    
    serializeJson(doc, buffer, size);
}

void Telemetry::printBuffer() {
    Serial.print(F("Telemetry Buffer: "));
    Serial.print(_buffer.count);
    Serial.print(F("/"));
    Serial.println(TELEMETRY_BUFFER_SIZE);
}