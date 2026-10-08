#include "TemperatureSensor.h"
#include "Config.h"

OneWire TemperatureSensor::_oneWire(PIN_ONEWIRE);
DallasTemperature TemperatureSensor::_sensors(&TemperatureSensor::_oneWire);
float TemperatureSensor::_last_temp = -127.0;
uint32_t TemperatureSensor::_last_read = 0;
bool TemperatureSensor::_initialized = false;
uint8_t TemperatureSensor::_crc_errors = 0;

void TemperatureSensor::init() {
    _sensors.begin();
    _sensors.setResolution(12);
    _sensors.setWaitForConversion(false);
    _initialized = true;
    _last_read = 0;
    Serial.println(F("Temperature Sensor initialized"));
}

void TemperatureSensor::read() {
    uint32_t now = millis();
    if (now - _last_read < TEMP_INTERVAL_MS) return;
    _last_read = now;
    
    if (!_initialized) init();
    
    _sensors.requestTemperatures();
    delay(750);
    
    float temp = _sensors.getTempCByIndex(0);
    
    if (temp != DEVICE_DISCONNECTED_C && temp > -55.0 && temp < 125.0) {
        _last_temp = temp;
        _crc_errors = 0;
    } else {
        _crc_errors++;
        if (_crc_errors >= 5) {
            _last_temp = -127.0;
        }
    }
}

float TemperatureSensor::getTemperature() {
    return _last_temp;
}

bool TemperatureSensor::isValid() {
    return _last_temp != -127.0 && _last_temp > -55.0 && _last_temp < 125.0;
}

void TemperatureSensor::printStatus() {
    Serial.print(F("Temperature: "));
    if (isValid()) {
        Serial.print(_last_temp, 2);
        Serial.println(F(" C"));
    } else {
        Serial.println(F("ERROR"));
    }
    Serial.print(F("CRC Errors: "));
    Serial.println(_crc_errors);
}