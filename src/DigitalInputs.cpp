#include "DigitalInputs.h"
#include "Config.h"
#include "Telemetry.h"

uint8_t DigitalInputs::_pins[NUM_DIGITAL_INPUTS] = {
    PIN_ED0, PIN_ED1, PIN_ED2, PIN_ED3, PIN_ED4, PIN_ED5
};
uint32_t DigitalInputs::_last_poll = 0;
uint8_t DigitalInputs::_prev_state[NUM_DIGITAL_INPUTS] = {255, 255, 255, 255, 255, 255};

void DigitalInputs::init() {
    for (uint8_t i = 0; i < NUM_DIGITAL_INPUTS; i++) {
        pinMode(_pins[i], INPUT_PULLUP);
        g_di_state[i].state = ED_STATE_NORMAL;
        g_di_state[i].counter_mas = 0;
        g_di_state[i].counter_menos = 0;
        g_di_state[i].evmas = false;
        g_di_state[i].evmenos = false;
        g_di_state[i].last_raw = digitalRead(_pins[i]) ^ ((Config::g_config.edpol >> i) & 0x01);
    }
    _last_poll = millis();
    Serial.println(F("Digital Inputs initialized"));
}

void DigitalInputs::poll() {
    uint32_t now = millis();
    if (now - _last_poll < INPUT_POLL_MS) return;
    _last_poll = now;
    
    for (uint8_t i = 0; i < NUM_DIGITAL_INPUTS; i++) {
        if (!(Config::g_config.edhab & (1 << i))) continue;
        
        uint8_t raw = digitalRead(_pins[i]);
        uint8_t pol = (Config::g_config.edpol >> i) & 0x01;
        uint8_t current = raw ^ pol;
        
        DigitalInputState_t& st = g_di_state[i];
        
        switch (st.state) {
            case ED_STATE_NORMAL:
                if (current == 0) {
                    st.state = ED_STATE_PRE_ALARM;
                    st.counter_mas = 0;
                }
                break;
                
            case ED_STATE_ALARM:
                if (current == 1) {
                    st.state = ED_STATE_PRE_NORMAL;
                    st.counter_menos = 0;
                }
                break;
                
            case ED_STATE_PRE_ALARM:
                if (current == 1) {
                    st.state = ED_STATE_NORMAL;
                    st.counter_mas = 0;
                } else {
                    st.counter_mas++;
                    if (st.counter_mas >= Config::g_config.tredmas[i]) {
                        st.state = ED_STATE_ALARM;
                        st.evmas = true;
                        _generateTelemetry(i, true);
                    }
                }
                break;
                
            case ED_STATE_PRE_NORMAL:
                if (current == 0) {
                    st.state = ED_STATE_ALARM;
                    st.counter_menos = 0;
                } else {
                    st.counter_menos++;
                    if (st.counter_menos >= Config::g_config.tredmenos[i]) {
                        st.state = ED_STATE_NORMAL;
                        st.evmenos = true;
                        _generateTelemetry(i, false);
                    }
                }
                break;
        }
        
        st.last_raw = current;
    }
}

void DigitalInputs::_checkEdge(uint8_t index, uint8_t current_raw) {
    DigitalInputState_t& st = g_di_state[index];
    uint8_t prev = st.last_raw;
    
    if (prev != current_raw) {
        if (current_raw == 1 && prev == 0) {
            st.evmas = true;
        } else if (current_raw == 0 && prev == 1) {
            st.evmenos = true;
        }
    }
}

void DigitalInputs::_generateTelemetry(uint8_t index, bool rising) {
    TelemetryData_t data = {};
    data.has_timestamp = false;
    
    for (uint8_t i = 0; i < NUM_DIGITAL_INPUTS; i++) {
        if (Config::g_config.edhab & (1 << i)) {
            uint8_t val = g_di_state[i].last_raw;
            switch (i) {
                case 0: data.pt1 = val; break;
                case 1: data.pt2 = val; break;
                case 2: data.ac1 = val; break;
                case 3: data.tvs = val; break;
                case 4: data.pwr = val; break;
                case 5: data.temp = val; break;
            }
        }
    }
    
    data.cini = Config::getCntrIni();
    data.cinimdc = Config::getCntrIniMdc();
    
    Telemetry::enqueue(data);
}

void DigitalInputs::printStatus() {
    Serial.println(F("Digital Inputs Status:"));
    for (uint8_t i = 0; i < NUM_DIGITAL_INPUTS; i++) {
        Serial.print(F("  ED")); Serial.print(i + 1);
        Serial.print(F(" (")); Serial.print(Config::g_config.edname[i]); Serial.print(F(")"));
        Serial.print(F(" Pin=")); Serial.print(_pins[i]);
        Serial.print(F(" Raw=")); Serial.print(digitalRead(_pins[i]));
        Serial.print(F(" Pol=")); Serial.print((Config::g_config.edpol >> i) & 0x01);
        Serial.print(F(" State=")); 
        switch (g_di_state[i].state) {
            case ED_STATE_NORMAL: Serial.print(F("NORMAL")); break;
            case ED_STATE_ALARM: Serial.print(F("ALARM")); break;
            case ED_STATE_PRE_ALARM: Serial.print(F("PRE_ALARM")); break;
            case ED_STATE_PRE_NORMAL: Serial.print(F("PRE_NORMAL")); break;
        }
        Serial.print(F(" Cnt+=")); Serial.print(g_di_state[i].counter_mas);
        Serial.print(F(" Cnt-=")); Serial.print(g_di_state[i].counter_menos);
        Serial.print(F(" Ev+=")); Serial.print(g_di_state[i].evmas);
        Serial.print(F(" Ev-=")); Serial.println(g_di_state[i].evmenos);
    }
}

uint8_t DigitalInputs::getInputState(uint8_t index) {
    if (index >= NUM_DIGITAL_INPUTS) return 255;
    return g_di_state[index].state;
}

bool DigitalInputs::getInputRaw(uint8_t index) {
    if (index >= NUM_DIGITAL_INPUTS) return false;
    uint8_t raw = digitalRead(_pins[index]);
    uint8_t pol = (Config::g_config.edpol >> index) & 0x01;
    return raw ^ pol;
}

void DigitalInputs::setPolarity(uint8_t index, bool invert) {
    if (index >= NUM_DIGITAL_INPUTS) return;
    if (invert) Config::g_config.edpol |= (1 << index);
    else Config::g_config.edpol &= ~(1 << index);
    Config::save();
}

void DigitalInputs::setEnabled(uint8_t index, bool enable) {
    if (index >= NUM_DIGITAL_INPUTS) return;
    if (enable) Config::g_config.edhab |= (1 << index);
    else Config::g_config.edhab &= ~(1 << index);
    Config::save();
}

void DigitalInputs::setDebounceTime(uint8_t index, uint16_t time_ms) {
    if (index >= NUM_DIGITAL_INPUTS) return;
    Config::g_config.tredmas[index] = time_ms / 100;
    Config::save();
}

void DigitalInputs::setDebounceTimeOff(uint8_t index, uint16_t time_ms) {
    if (index >= NUM_DIGITAL_INPUTS) return;
    Config::g_config.tredmenos[index] = time_ms / 100;
    Config::save();
}

void DigitalInputs::forceUpdate() {
    _last_poll = 0;
    poll();
}