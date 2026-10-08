#pragma once

#include <Arduino.h>
#include <stdint.h>
#include <avr/eeprom.h>
#include <avr/wdt.h>

#define FIRMWARE_VERSION "1.0.0"
#define FIRMWARE_DATE "2026-10-08"
#define CONFIG_MAGIC 0xD1EC0000

// Pin Definitions for ATMEGA1284P
#define PIN_LED_STATUS      PB0
#define PIN_W5200_RESET     PB2
#define PIN_W5200_CS        PB3
// SPI pins are defined in Arduino core: PIN_SPI_MOSI (PB5), PIN_SPI_MISO (PB6), PIN_SPI_SCK (PB7)

#define PIN_ED0             PC0
#define PIN_ED1             PC1
#define PIN_ED2             PC2
#define PIN_ED3             PC3
#define PIN_ED4             PC4
#define PIN_ED5             PC5

#define PIN_ONEWIRE         PC5
#define PIN_ADC_VOLTAGE     PA2

#define NUM_DIGITAL_INPUTS  6
#define NUM_AUTO_TX         4
#define NUM_NTP_SERVERS     8
#define TELEMETRY_BUFFER_SIZE 16
#define MQTT_BUFFER_SIZE    512
#define SERIAL_BUFFER_SIZE  256
#define EEPROM_CONFIG_ADDR  0

#define DEBOUNCE_TICKS      20
#define ADC_SAMPLES         4
#define ADC_INTERVAL_MS     5000
#define TEMP_INTERVAL_MS    5000
#define MQTT_KEEPALIVE_SEC  60
#define INPUT_POLL_MS       100

#define ED_STATE_NORMAL     0
#define ED_STATE_ALARM      1
#define ED_STATE_PRE_ALARM  2
#define ED_STATE_PRE_NORMAL 3

#define CMD_MAX_PARAMS      16
#define CMD_MAX_LEN         64

typedef struct {
    uint8_t ip[4];
    uint8_t gateway[4];
    uint8_t mask[4];
    uint8_t mac[6];
    char mqtt_server[64];
    uint16_t mqtt_port;
    char device_token[32];
    uint16_t tredmas[NUM_DIGITAL_INPUTS];
    uint16_t tredmenos[NUM_DIGITAL_INPUTS];
    uint8_t edpol;
    uint8_t edhab;
    char edname[NUM_DIGITAL_INPUTS][7];
    uint32_t autoval[NUM_AUTO_TX];
    uint32_t offset[NUM_AUTO_TX];
    float adc_k;
    char ntp_servers[NUM_NTP_SERVERS][16];
    uint16_t cntrini;
    uint16_t cntrinimdc;
    uint32_t magic;
} Config_t;

typedef struct {
    uint8_t state;
    uint16_t counter_mas;
    uint16_t counter_menos;
    bool evmas;
    bool evmenos;
    uint8_t last_raw;
} DigitalInputState_t;

typedef struct {
    char timestamp[24];
    float pt1, pt2, ac1, tvs;
    float pwr, temp;
    uint16_t cini, cinimdc;
    bool has_timestamp;
} TelemetryData_t;

typedef struct {
    TelemetryData_t data[TELEMETRY_BUFFER_SIZE];
    uint8_t head;
    uint8_t tail;
    uint8_t count;
} TelemetryBuffer_t;

typedef struct {
    char cmd[CMD_MAX_LEN];
    char params[CMD_MAX_PARAMS][CMD_MAX_LEN];
    uint8_t param_count;
} ParsedCommand_t;

extern Config_t g_config;
extern DigitalInputState_t g_di_state[NUM_DIGITAL_INPUTS];
extern TelemetryBuffer_t g_telemetry_buffer;
extern volatile uint32_t g_millis;
extern volatile uint16_t g_timer1_tick;

void initPins();
void resetFunc();
uint32_t getMillis();
void feedWatchdog();
void enableWatchdog();
void disableWatchdog();