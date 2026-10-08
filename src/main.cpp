#include <Arduino.h>
#include <avr/wdt.h>
#include "DITECNETMQTT.h"
#include "Config.h"
#include "EthernetManager.h"
#include "MQTTHandler.h"
#include "DigitalInputs.h"
#include "TemperatureSensor.h"
#include "VoltageMonitor.h"
#include "Telemetry.h"
#include "LedStatus.h"
#include "SerialParser.h"

Config_t g_config;
DigitalInputState_t g_di_state[NUM_DIGITAL_INPUTS];
TelemetryBuffer_t g_telemetry_buffer;
volatile uint32_t g_millis = 0;
volatile uint16_t g_timer1_tick = 0;

void initPins() {
    pinMode(PIN_LED_STATUS, OUTPUT);
    digitalWrite(PIN_LED_STATUS, LOW);
    
    pinMode(PIN_W5200_RESET, OUTPUT);
    digitalWrite(PIN_W5200_RESET, HIGH);
    
    pinMode(PIN_W5200_CS, OUTPUT);
    digitalWrite(PIN_W5200_CS, HIGH);
}

void resetFunc() {
    wdt_enable(WDTO_15MS);
    while(1);
}

uint32_t getMillis() {
    return millis();
}

void feedWatchdog() {
    wdt_reset();
}

void enableWatchdog() {
    wdt_enable(WDTO_8S);
}

void disableWatchdog() {
    wdt_disable();
}

void setup() {
    MCUSR = 0;
    wdt_disable();
    
    initPins();
    
    Serial.begin(115200);
    while (!Serial && millis() < 2000);
    
    Serial.println();
    Serial.println(F("************ DITECNETMQTT ************"));
    Serial.print(F("Version: ")); Serial.println(FIRMWARE_VERSION);
    Serial.print(F("Date: ")); Serial.println(FIRMWARE_DATE);
    
    Config::load();
    Config::printConfig();
    Config::incrementCntrIni();
    
    SerialParser::init();
    
    EthernetManager::init();
    
    MQTTHandler::init();
    
    DigitalInputs::init();
    
    TemperatureSensor::init();
    
    VoltageMonitor::init();
    
    Telemetry::init();
    
    LedStatus::init();
    LedStatus::setPattern(1);
    
    enableWatchdog();
    
    Serial.println(F("Setup complete"));
    Serial.println(F("System ready"));
}

void loop() {
    feedWatchdog();
    
    MQTTHandler::loop();
    
    EthernetManager::maintain();
    
    DigitalInputs::poll();
    
    TemperatureSensor::read();
    
    VoltageMonitor::read();
    
    Telemetry::sendPeriodic();
    
    if (!Telemetry::isEmpty() && MQTTHandler::isConnected()) {
        Telemetry::sendNext();
    }
    
    SerialParser::process();
    
    LedStatus::update();
}