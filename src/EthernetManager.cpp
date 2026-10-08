#include "EthernetManager.h"
#include "Config.h"
#include <SPI.h>
#include <Ethernet_Generic.h>

EthernetClient _eth_client;
bool EthernetManager::_initialized = false;
uint32_t EthernetManager::_last_maintain = 0;

bool EthernetManager::init() {
    pinMode(PIN_W5200_RESET, OUTPUT);
    pinMode(PIN_W5200_CS, OUTPUT);
    
    digitalWrite(PIN_W5200_RESET, LOW);
    delay(250);
    digitalWrite(PIN_W5200_RESET, HIGH);
    delay(250);
    
    SPI.begin();
    SPI.setClockDivider(SPI_CLOCK_DIV4);
    
    IPAddress ip(Config::g_config.ip[0], Config::g_config.ip[1], 
                 Config::g_config.ip[2], Config::g_config.ip[3]);
    IPAddress gateway(Config::g_config.gateway[0], Config::g_config.gateway[1], 
                      Config::g_config.gateway[2], Config::g_config.gateway[3]);
    IPAddress subnet(Config::g_config.mask[0], Config::g_config.mask[1], 
                     Config::g_config.mask[2], Config::g_config.mask[3]);
    
    Ethernet.init(PIN_W5200_CS);
    Ethernet.begin(Config::g_config.mac, ip, gateway, subnet);
    
    delay(1000);
    
    _initialized = true;
    _last_maintain = millis();
    
    Serial.print(F("Ethernet initialized: "));
    Serial.println(Ethernet.localIP());
    
    return isConnected();
}

bool EthernetManager::isConnected() {
    return Ethernet.linkStatus() == LinkON;
}

void EthernetManager::maintain() {
    if (millis() - _last_maintain > 5000) {
        _last_maintain = millis();
        if (!isConnected()) {
            Serial.println(F("Ethernet link down, reinitializing..."));
            reset();
            init();
        }
    }
}

void EthernetManager::printStatus() {
    Serial.print(F("IP: ")); Serial.println(Ethernet.localIP());
    Serial.print(F("GW: ")); Serial.println(Ethernet.gatewayIP());
    Serial.print(F("Mask: ")); Serial.println(Ethernet.subnetMask());
    Serial.print(F("Link: ")); Serial.println(isConnected() ? F("UP") : F("DOWN"));
}

Client& EthernetManager::getClient() {
    return _eth_client;
}

void EthernetManager::reset() {
    digitalWrite(PIN_W5200_RESET, LOW);
    delay(250);
    digitalWrite(PIN_W5200_RESET, HIGH);
    delay(500);
    _initialized = false;
}