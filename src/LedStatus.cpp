#include "LedStatus.h"

const uint32_t LedStatus::_patterns[17] = {
    0x00000000,
    0x00000003,
    0x00000333,
    0x00003333,
    0x00333333,
    0x03333333,
    0x0C000333,
    0x0FFFFFFF,
    0x55555555,
    0x33333333,
    0x77777777,
    0xAAAAAAAA,
    0xFFFF00CC,
    0xFFFF0CCC,
    0xFFFF3333,
    0xFFFFFF00,
    0xFFFFFFFF
};

uint8_t LedStatus::_current_pattern = 1;
uint8_t LedStatus::_window = 0;
uint32_t LedStatus::_last_update = 0;

void LedStatus::init() {
    pinMode(PIN_LED_STATUS, OUTPUT);
    digitalWrite(PIN_LED_STATUS, LOW);
    _current_pattern = 1;
    _window = 0;
    _last_update = 0;
    Serial.println(F("LED Status initialized"));
}

void LedStatus::update() {
    uint32_t now = millis();
    if (now - _last_update < 31) return;
    _last_update = now;
    
    _window = (_window + 1) & 0x1F;
    bool state = (_patterns[_current_pattern] >> _window) & 0x01;
    _setLed(state);
}

void LedStatus::_setLed(bool on) {
    digitalWrite(PIN_LED_STATUS, on ? HIGH : LOW);
}

void LedStatus::setPattern(uint8_t pattern) {
    if (pattern <= 16) {
        _current_pattern = pattern;
    }
}

uint8_t LedStatus::getPattern() {
    return _current_pattern;
}

void LedStatus::printStatus() {
    Serial.print(F("LED Pattern: "));
    Serial.println(_current_pattern);
}