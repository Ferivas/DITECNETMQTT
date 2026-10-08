#include "Config.h"
#include <EEPROM.h>
#include <string.h>

Config_t Config::g_config;

bool Config::load() {
    EEPROM.get(EEPROM_CONFIG_ADDR, g_config);
    if (g_config.magic != CONFIG_MAGIC) {
        loadDefaults();
        save();
        return false;
    }
    return true;
}

void Config::save() {
    g_config.magic = CONFIG_MAGIC;
    EEPROM.put(EEPROM_CONFIG_ADDR, g_config);
}

void Config::loadDefaults() {
    g_config.ip[0] = 192; g_config.ip[1] = 168; g_config.ip[2] = 0; g_config.ip[3] = 57;
    g_config.gateway[0] = 192; g_config.gateway[1] = 168; g_config.gateway[2] = 0; g_config.gateway[3] = 1;
    g_config.mask[0] = 255; g_config.mask[1] = 255; g_config.mask[2] = 255; g_config.mask[3] = 0;
    g_config.mac[0] = 0x00; g_config.mac[1] = 0x08; g_config.mac[2] = 0xDC; 
    g_config.mac[3] = 0x01; g_config.mac[4] = 0x01; g_config.mac[5] = 0x22;
    
    strncpy(g_config.mqtt_server, "thingsboard.cloud", sizeof(g_config.mqtt_server) - 1);
    g_config.mqtt_port = 1883;
    strncpy(g_config.device_token, "eljtyKCqdobh2MDSXbPa", sizeof(g_config.device_token) - 1);
    
    for (uint8_t i = 0; i < NUM_DIGITAL_INPUTS; i++) {
        g_config.tredmas[i] = 20;
        g_config.tredmenos[i] = 20;
    }
    g_config.tredmas[2] = 50;
    g_config.tredmenos[2] = 50;
    
    g_config.edpol = 0;
    g_config.edhab = 0x05;
    
    strncpy(g_config.edname[0], "PT1", 6);
    strncpy(g_config.edname[1], "PT2", 6);
    strncpy(g_config.edname[2], "AC", 6);
    strncpy(g_config.edname[3], "TVS", 6);
    strncpy(g_config.edname[4], "ED5", 6);
    strncpy(g_config.edname[5], "ED6", 6);
    
    g_config.autoval[0] = 300;
    g_config.autoval[1] = 43200;
    g_config.autoval[2] = 43200;
    g_config.autoval[3] = 7200;
    
    g_config.offset[0] = 0;
    g_config.offset[1] = 120;
    g_config.offset[2] = 30;
    g_config.offset[3] = 60;
    
    g_config.adc_k = 0.004297432f;
    
    strncpy(g_config.ntp_servers[0], "129.6.15.28", 15);
    strncpy(g_config.ntp_servers[1], "132.163.97.1", 15);
    strncpy(g_config.ntp_servers[2], "132.163.97.2", 15);
    strncpy(g_config.ntp_servers[3], "132.163.97.3", 15);
    strncpy(g_config.ntp_servers[4], "132.163.96.1", 15);
    strncpy(g_config.ntp_servers[5], "132.163.96.2", 15);
    strncpy(g_config.ntp_servers[6], "128.138.140.44", 15);
    strncpy(g_config.ntp_servers[7], "128.138.141.172", 15);
    
    g_config.cntrini = 0;
    g_config.cntrinimdc = 0;
    g_config.magic = CONFIG_MAGIC;
}

void Config::printConfig() {
    Serial.print(F("IP: "));
    for (int i = 0; i < 4; i++) {
        Serial.print(g_config.ip[i]);
        if (i < 3) Serial.print(F("."));
    }
    Serial.println();
    
    Serial.print(F("Gateway: "));
    for (int i = 0; i < 4; i++) {
        Serial.print(g_config.gateway[i]);
        if (i < 3) Serial.print(F("."));
    }
    Serial.println();
    
    Serial.print(F("Mask: "));
    for (int i = 0; i < 4; i++) {
        Serial.print(g_config.mask[i]);
        if (i < 3) Serial.print(F("."));
    }
    Serial.println();
    
    Serial.print(F("MAC: "));
    for (int i = 0; i < 6; i++) {
        if (g_config.mac[i] < 0x10) Serial.print(F("0"));
        Serial.print(g_config.mac[i], HEX);
        if (i < 5) Serial.print(F(":"));
    }
    Serial.println();
    
    Serial.print(F("MQTT Server: ")); Serial.println(g_config.mqtt_server);
    Serial.print(F("MQTT Port: ")); Serial.println(g_config.mqtt_port);
    Serial.print(F("Token: ")); Serial.println(g_config.device_token);
    
    for (int i = 0; i < NUM_DIGITAL_INPUTS; i++) {
        Serial.print(F("ED")); Serial.print(i + 1); Serial.print(F(": "));
        Serial.print(g_config.edname[i]); Serial.print(F(" T+="));
        Serial.print(g_config.tredmas[i]); Serial.print(F(" T-="));
        Serial.print(g_config.tredmenos[i]); Serial.println();
    }
    
    Serial.print(F("EDPOL: ")); Serial.println(g_config.edpol, BIN);
    Serial.print(F("EDHAB: ")); Serial.println(g_config.edhab, BIN);
    Serial.print(F("ADC K: ")); Serial.println(g_config.adc_k, 9);
    Serial.print(F("CNTRINI: ")); Serial.println(g_config.cntrini);
    Serial.print(F("CNTRINIMDC: ")); Serial.println(g_config.cntrinimdc);
}

bool Config::isValid() {
    return g_config.magic == CONFIG_MAGIC;
}

void Config::incrementCntrIni() {
    g_config.cntrini++;
    save();
}

void Config::incrementCntrIniMdc() {
    g_config.cntrinimdc++;
    save();
}

uint16_t Config::getCntrIni() {
    return g_config.cntrini;
}

uint16_t Config::getCntrIniMdc() {
    return g_config.cntrinimdc;
}

void Config::setCntrIni(uint16_t val) {
    g_config.cntrini = val;
    save();
}

void Config::setCntrIniMdc(uint16_t val) {
    g_config.cntrinimdc = val;
    save();
}