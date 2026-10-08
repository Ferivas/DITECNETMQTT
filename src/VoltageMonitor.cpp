#include "VoltageMonitor.h"
#include "Config.h"

float VoltageMonitor::_voltage = 0.0;
uint32_t VoltageMonitor::_last_read = 0;
uint16_t VoltageMonitor::_sample_sum = 0;
uint8_t VoltageMonitor::_sample_count = 0;
bool VoltageMonitor::_ready = false;

void VoltageMonitor::init() {
    ADMUX = (1 << REFS0) | (PIN_ADC_VOLTAGE & 0x07);
    ADCSRA = (1 << ADEN) | (1 << ADPS2) | (1 << ADPS1) | (1 << ADPS0);
    _last_read = 0;
    _sample_sum = 0;
    _sample_count = 0;
    _ready = false;
    Serial.println(F("Voltage Monitor initialized"));
}

void VoltageMonitor::read() {
    uint32_t now = millis();
    if (now - _last_read < ADC_INTERVAL_MS / ADC_SAMPLES) return;
    _last_read = now;
    
    ADCSRA |= (1 << ADSC);
    while (ADCSRA & (1 << ADSC));
    
    uint16_t val = ADC;
    _sample_sum += val;
    _sample_count++;
    
    if (_sample_count >= ADC_SAMPLES) {
        float avg = _sample_sum / (float)ADC_SAMPLES;
        _voltage = avg * Config::g_config.adc_k + 0.3;
        _sample_sum = 0;
        _sample_count = 0;
        _ready = true;
    }
}

float VoltageMonitor::getVoltage() {
    return _voltage;
}

bool VoltageMonitor::isReady() {
    bool r = _ready;
    _ready = false;
    return r;
}

void VoltageMonitor::setCalibration(float k) {
    Config::g_config.adc_k = k;
    Config::save();
}

void VoltageMonitor::printStatus() {
    Serial.print(F("Voltage: "));
    Serial.print(_voltage, 2);
    Serial.println(F(" V"));
    Serial.print(F("ADC K: "));
    Serial.println(Config::g_config.adc_k, 9);
}