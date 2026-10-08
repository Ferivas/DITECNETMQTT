#include "SerialParser.h"
#include "Config.h"
#include "DigitalInputs.h"
#include "TemperatureSensor.h"
#include "VoltageMonitor.h"
#include "EthernetManager.h"
#include "MQTTHandler.h"
#include "Telemetry.h"
#include "LedStatus.h"
#include <string.h>
#include <stdlib.h>
#include <avr/boot.h>

char SerialParser::_buffer[SERIAL_BUFFER_SIZE];
uint16_t SerialParser::_buffer_pos = 0;

void SerialParser::init() {
    _buffer_pos = 0;
    memset(_buffer, 0, SERIAL_BUFFER_SIZE);
    Serial.println(F("Serial Parser initialized"));
}

void SerialParser::process() {
    while (Serial.available()) {
        char c = Serial.read();
        
        if (c == '\r') continue;
        
        if (c == '\n') {
            _buffer[_buffer_pos] = '\0';
            if (_buffer_pos > 0) {
                ParsedCommand_t parsed = _parseCommand(_buffer);
                _executeCommand(parsed);
            }
            _buffer_pos = 0;
        } else if (_buffer_pos < SERIAL_BUFFER_SIZE - 1) {
            _buffer[_buffer_pos++] = c;
        }
    }
}

ParsedCommand_t SerialParser::_parseCommand(const char* cmd) {
    ParsedCommand_t parsed = {{0}, {{0}}, 0};
    
    char* token = strtok(const_cast<char*>(cmd), ",");
    if (token) {
        strncpy(parsed.cmd, token, CMD_MAX_LEN - 1);
        
        while ((token = strtok(nullptr, ",")) && parsed.param_count < CMD_MAX_PARAMS) {
            strncpy(parsed.params[parsed.param_count], token, CMD_MAX_LEN - 1);
            parsed.param_count++;
        }
    }
    
    for (char* c = parsed.cmd; *c; c++) {
        *c = toupper(*c);
    }
    
    return parsed;
}

void SerialParser::_executeCommand(const ParsedCommand_t& p) {
    const char* cmd = p.cmd;
    char resp[256];
    
    if (strcmp(cmd, "LEEVFW") == 0) {
        sprintf(resp, "Version FW: Fecha <%s>, Archivo <%s>", FIRMWARE_DATE, FIRMWARE_VERSION);
        _sendResponse(resp);
    }
    else if (strcmp(cmd, "LEERID") == 0) {
        char id[21];
        uint32_t uid = 0;
        // Read unique ID from signature row
        for (int i = 0; i < 10; i++) {
            uint8_t b = boot_signature_byte_get(0x0E + i);
            uid = (uid << 8) | b;
        }
        sprintf(id, "%08lX%02X%02X", uid >> 16, (uid >> 8) & 0xFF, uid & 0xFF);
        sprintf(resp, "ID ser <%s>", id);
        _sendResponse(resp);
    }
    else if (strcmp(cmd, "SETIPX") == 0) {
        if (p.param_count >= 1 && _parseIP(p.params[0], Config::g_config.ip)) {
            Config::save();
            sprintf(resp, "Se configuro Ip <%s>", p.params[0]);
            _sendResponse(resp);
        } else _sendResponse("$ERROR5");
    }
    else if (strcmp(cmd, "SETPTX") == 0) {
        if (p.param_count >= 1) {
            Config::g_config.mqtt_port = atoi(p.params[0]);
            Config::save();
            sprintf(resp, "Se configuro Puerto <%s>", p.params[0]);
            _sendResponse(resp);
        } else _sendResponse("$ERROR4");
    }
    else if (strcmp(cmd, "LEEIPX") == 0) {
        sprintf(resp, "Ip <%d.%d.%d.%d>", 
                Config::g_config.ip[0], Config::g_config.ip[1], 
                Config::g_config.ip[2], Config::g_config.ip[3]);
        _sendResponse(resp);
    }
    else if (strcmp(cmd, "LEEPTX") == 0) {
        sprintf(resp, "Puerto <%d>", Config::g_config.mqtt_port);
        _sendResponse(resp);
    }
    else if (strcmp(cmd, "RSTVAR") == 0) {
        Config::loadDefaults();
        Config::save();
        _sendResponse("Se configuran parametros a valores por defecto");
    }
    else if (strcmp(cmd, "SETCFG") == 0) {
        if (p.param_count >= 1) {
            sprintf(resp, "Se configura CFGOK=%s", p.params[0]);
            _sendResponse(resp);
        } else _sendResponse("$ERROR4");
    }
    else if (strcmp(cmd, "SETKTB") == 0) {
        if (p.param_count >= 1) {
            strncpy(Config::g_config.device_token, p.params[0], 31);
            Config::save();
            sprintf(resp, "Se configuro APIkey TB<%s>", p.params[0]);
            _sendResponse(resp);
        } else _sendResponse("$ERROR4");
    }
    else if (strcmp(cmd, "LEEKTB") == 0) {
        sprintf(resp, "APIkey TB <%s>", Config::g_config.device_token);
        _sendResponse(resp);
    }
    else if (strcmp(cmd, "SETBUG") == 0) {
        sprintf(resp, "Se habilita debug a %s", p.param_count >= 1 ? p.params[0] : "0");
        _sendResponse(resp);
    }
    else if (strcmp(cmd, "LEEBUG") == 0) {
        _sendResponse("ENABUG=0");
    }
    else if (strcmp(cmd, "SETADC") == 0) {
        if (p.param_count >= 1) {
            VoltageMonitor::setCalibration(atof(p.params[0]));
            sprintf(resp, "Se configuro K de ADC a %s", p.params[0]);
            _sendResponse(resp);
        } else _sendResponse("$ERROR4");
    }
    else if (strcmp(cmd, "LEEADC") == 0) {
        sprintf(resp, "K de ADC =%.9f", Config::g_config.adc_k);
        _sendResponse(resp);
    }
    else if (strcmp(cmd, "LEEVDC") == 0) {
        sprintf(resp, "Voltaje de alimentacion=%.2f", VoltageMonitor::getVoltage());
        _sendResponse(resp);
    }
    else if (strcmp(cmd, "SETAUT") == 0) {
        if (p.param_count >= 2) {
            uint8_t idx = atoi(p.params[0]) - 1;
            if (idx < 4) {
                Config::g_config.autoval[idx] = atol(p.params[1]);
                Config::save();
                sprintf(resp, "Se configuro tx AUT %d:%lu", idx+1, Config::g_config.autoval[idx]);
                _sendResponse(resp);
            } else _sendResponse("$ERROR3");
        } else _sendResponse("$ERROR4");
    }
    else if (strcmp(cmd, "SETOFF") == 0) {
        if (p.param_count >= 2) {
            uint8_t idx = atoi(p.params[0]) - 1;
            if (idx < 4) {
                Config::g_config.offset[idx] = atol(p.params[1]);
                Config::save();
                sprintf(resp, "Se configuro tx AUT %d:%lu", idx+1, Config::g_config.offset[idx]);
                _sendResponse(resp);
            } else _sendResponse("$ERROR3");
        } else _sendResponse("$ERROR4");
    }
    else if (strcmp(cmd, "LEEAUT") == 0) {
        if (p.param_count >= 1) {
            uint8_t idx = atoi(p.params[0]) - 1;
            if (idx < 4) {
                sprintf(resp, "Tx Aut %d:%lu", idx+1, Config::g_config.autoval[idx]);
                _sendResponse(resp);
            } else _sendResponse("$ERROR3");
        } else _sendResponse("$ERROR4");
    }
    else if (strcmp(cmd, "LEEOFF") == 0) {
        if (p.param_count >= 1) {
            uint8_t idx = atoi(p.params[0]) - 1;
            if (idx < 4) {
                sprintf(resp, "Offset Aut %d:%lu", idx+1, Config::g_config.offset[idx]);
                _sendResponse(resp);
            } else _sendResponse("$ERROR3");
        } else _sendResponse("$ERROR4");
    }
    else if (strcmp(cmd, "SETNEW") == 0) {
        if (p.param_count >= 1) {
            uint8_t idx = atoi(p.params[0]) - 1;
            if (idx < 4) {
                sprintf(resp, "Se activo Tx. AUT %d", idx+1);
                _sendResponse(resp);
            } else _sendResponse("$ERROR3");
        } else _sendResponse("$ERROR4");
    }
    else if (strcmp(cmd, "SETINI") == 0) {
        if (p.param_count >= 1) {
            Config::setCntrIni(atoi(p.params[0]));
            sprintf(resp, "Se configuro Contador Inicios: %s", p.params[0]);
            _sendResponse(resp);
        } else _sendResponse("$ERROR4");
    }
    else if (strcmp(cmd, "LEEINI") == 0) {
        sprintf(resp, "Contador inicios <%d>", Config::getCntrIni());
        _sendResponse(resp);
    }
    else if (strcmp(cmd, "SETINM") == 0) {
        if (p.param_count >= 1) {
            Config::setCntrIniMdc(atoi(p.params[0]));
            sprintf(resp, "Se configuro Contador Inicios MDC: %s", p.params[0]);
            _sendResponse(resp);
        } else _sendResponse("$ERROR4");
    }
    else if (strcmp(cmd, "LEEINM") == 0) {
        sprintf(resp, "Contador inicios MDC<%d>", Config::getCntrIniMdc());
        _sendResponse(resp);
    }
    else if (strcmp(cmd, "ESTADO") == 0) {
        sprintf(resp, "WATCHING INFORMA. PT1=%d, PT2=%d, AC=%d, TVSS=%d, VIN=%.2f, T=%.2f",
                g_di_state[0].last_raw, g_di_state[1].last_raw,
                g_di_state[2].last_raw, g_di_state[3].last_raw,
                VoltageMonitor::getVoltage(), TemperatureSensor::getTemperature());
        _sendResponse(resp);
    }
    else if (strcmp(cmd, "LEERED") == 0) {
        sprintf(resp, "WATCHING INFORMA. ED1=%d, ED2=%d, ED3=%d, ED4=%d",
                g_di_state[0].last_raw, g_di_state[1].last_raw,
                g_di_state[2].last_raw, g_di_state[3].last_raw);
        _sendResponse(resp);
    }
    else if (strcmp(cmd, "INIMDM") == 0) {
        if (p.param_count >= 1 && atoi(p.params[0]) == 1) {
            EthernetManager::reset();
            EthernetManager::init();
            MQTTHandler::reconnect();
            _sendResponse("Iniciar MDM");
        } else {
            _sendResponse("Apagar MDM");
        }
    }
    else if (strcmp(cmd, "RESETS") == 0) {
        _sendResponse("Reset por software");
        delay(100);
        wdt_enable(WDTO_15MS);
        while(1);
    }
    else if (strcmp(cmd, "INIVAR") == 0) {
        Config::load();
        _sendResponse("Reinicio de variables");
    }
    else if (strcmp(cmd, "SETHAB") == 0) {
        if (p.param_count >= 2) {
            uint8_t idx = atoi(p.params[0]) - 1;
            uint8_t val = atoi(p.params[1]);
            DigitalInputs::setEnabled(idx, val);
            sprintf(resp, "Se configuro HAB ED%d=%s", idx+1, val ? "1" : "0");
            _sendResponse(resp);
        } else _sendResponse("$ERROR4");
    }
    else if (strcmp(cmd, "LEEHAB") == 0) {
        sprintf(resp, "Hab ED=%d", Config::g_config.edhab);
        _sendResponse(resp);
    }
    else if (strcmp(cmd, "SETNET") == 0) {
        if (p.param_count >= 2) {
            uint8_t type = atoi(p.params[0]);
            if (type == 1 && _parseIP(p.params[1], Config::g_config.ip)) {
                Config::save();
                sprintf(resp, "Se configuro IP DITEC a <%s>", p.params[1]);
                _sendResponse(resp);
            }
            else if (type == 2 && _parseIP(p.params[1], Config::g_config.gateway)) {
                Config::save();
                sprintf(resp, "Se configuro IP GATEWAY a <%s>", p.params[1]);
                _sendResponse(resp);
            }
            else if (type == 3 && _parseIP(p.params[1], Config::g_config.mask)) {
                Config::save();
                sprintf(resp, "Se configuro IP MASK a <%s>", p.params[1]);
                _sendResponse(resp);
            }
            else if (type == 4 && _parseMAC(p.params[1], Config::g_config.mac)) {
                Config::save();
                sprintf(resp, "Se configuro MAC Address <%s>", p.params[1]);
                _sendResponse(resp);
            }
            else _sendResponse("$ERROR6");
        } else _sendResponse("$ERROR4");
    }
    else if (strcmp(cmd, "LEENET") == 0) {
        if (p.param_count >= 1) {
            uint8_t type = atoi(p.params[0]);
            if (type == 1) {
                sprintf(resp, "IP DITEC <%d.%d.%d.%d>", 
                        Config::g_config.ip[0], Config::g_config.ip[1],
                        Config::g_config.ip[2], Config::g_config.ip[3]);
            } else if (type == 2) {
                sprintf(resp, "IP GATEWAY <%d.%d.%d.%d>", 
                        Config::g_config.gateway[0], Config::g_config.gateway[1],
                        Config::g_config.gateway[2], Config::g_config.gateway[3]);
            } else if (type == 3) {
                sprintf(resp, "IP MASK <%d.%d.%d.%d>", 
                        Config::g_config.mask[0], Config::g_config.mask[1],
                        Config::g_config.mask[2], Config::g_config.mask[3]);
            } else if (type == 4) {
                sprintf(resp, "MAC Address <%02X:%02X:%02X:%02X:%02X:%02X>",
                        Config::g_config.mac[0], Config::g_config.mac[1],
                        Config::g_config.mac[2], Config::g_config.mac[3],
                        Config::g_config.mac[4], Config::g_config.mac[5]);
            } else {
                _sendResponse("$ERROR6");
                return;
            }
            _sendResponse(resp);
        } else _sendResponse("$ERROR4");
    }
    else if (strcmp(cmd, "SETPOL") == 0) {
        if (p.param_count >= 2) {
            uint8_t idx = atoi(p.params[0]) - 1;
            uint8_t val = atoi(p.params[1]);
            DigitalInputs::setPolarity(idx, val);
            sprintf(resp, "Se configuro Pol ED%d=%s", idx+1, val ? "1" : "0");
            _sendResponse(resp);
        } else _sendResponse("$ERROR4");
    }
    else if (strcmp(cmd, "LEEPOL") == 0) {
        sprintf(resp, "POL ED=%d", Config::g_config.edpol);
        _sendResponse(resp);
    }
    else if (strcmp(cmd, "SETPAR") == 0) {
        if (p.param_count >= 4) {
            uint8_t type = atoi(p.params[0]);
            uint8_t idx = atoi(p.params[1]) - 1;
            uint8_t param = atoi(p.params[2]);
            
            if (type == 1 && idx < NUM_DIGITAL_INPUTS) {
                if (param == 1) {
                    strncpy(Config::g_config.edname[idx], p.params[3], 6);
                    Config::save();
                    sprintf(resp, "Se config nombre ED%d=%s", idx+1, p.params[3]);
                    _sendResponse(resp);
                }
                else if (param == 2) {
                    DigitalInputs::setPolarity(idx, atoi(p.params[3]));
                    sprintf(resp, "EDpol%d=%s", idx+1, p.params[3]);
                    _sendResponse(resp);
                }
                else if (param == 3) {
                    DigitalInputs::setDebounceTime(idx, atoi(p.params[3]) * 100);
                    sprintf(resp, "Se config Tactivacion + ED%d=%sx100ms", idx+1, p.params[3]);
                    _sendResponse(resp);
                }
                else if (param == 4) {
                    DigitalInputs::setDebounceTimeOff(idx, atoi(p.params[3]) * 100);
                    sprintf(resp, "Se config Tactivacion - ED%d=%sx100ms", idx+1, p.params[3]);
                    _sendResponse(resp);
                }
            }
        } else _sendResponse("$ERROR4");
    }
    else if (strcmp(cmd, "LEEPAR") == 0) {
        if (p.param_count >= 2) {
            uint8_t type = atoi(p.params[0]);
            uint8_t idx = atoi(p.params[1]) - 1;
            if (type == 1 && idx < NUM_DIGITAL_INPUTS) {
                sprintf(resp, "ED%d;Nombre=%s;POL=%d;Tact+=%dx100ms;Tact-=%dx100ms",
                        idx+1, Config::g_config.edname[idx],
                        (Config::g_config.edpol >> idx) & 1,
                        Config::g_config.tredmas[idx],
                        Config::g_config.tredmenos[idx]);
                _sendResponse(resp);
            }
        } else _sendResponse("$ERROR4");
    }
    else if (strcmp(cmd, "SETURL") == 0) {
        if (p.param_count >= 1) {
            strncpy(Config::g_config.mqtt_server, p.params[0], 63);
            Config::save();
            sprintf(resp, "Se config URL a %s", p.params[0]);
            _sendResponse(resp);
        } else _sendResponse("$ERROR4");
    }
    else if (strcmp(cmd, "LEEURL") == 0) {
        sprintf(resp, "URL>%s", Config::g_config.mqtt_server);
        _sendResponse(resp);
    }
    else if (strcmp(cmd, "HELP") == 0) {
        printHelp();
    }
    else {
        _sendResponse("$ERROR1");
    }
}

void SerialParser::_sendResponse(const char* msg) {
    Serial.println(msg);
}

void SerialParser::printHelp() {
    Serial.println(F("Comandos disponibles:"));
    Serial.println(F("  LEEVFW           - Version firmware"));
    Serial.println(F("  LEERID           - ID serial chip"));
    Serial.println(F("  SETIPX,<ip>      - IP servidor MQTT"));
    Serial.println(F("  STPTX,<port>     - Puerto MQTT"));
    Serial.println(F("  SETKTB,<token>   - Token Thingsboard"));
    Serial.println(F("  SETNET,1,<ip>    - IP modulo"));
    Serial.println(F("  SETNET,2,<ip>    - Gateway"));
    Serial.println(F("  SETNET,3,<ip>    - Mask"));
    Serial.println(F("  SETNET,4,<mac>   - MAC (12 hex)"));
    Serial.println(F("  SETAUT,<1-4>,<s> - Periodo envio auto"));
    Serial.println(F("  SETOFF,<1-4>,<s> - Offset envio auto"));
    Serial.println(F("  SETPAR,1,<1-6>,<1-4>,<val> - Params ED"));
    Serial.println(F("  SETHAB,<1-6>,<0/1> - Habilitar ED"));
    Serial.println(F("  SETPOL,<1-6>,<0/1> - Polaridad ED"));
    Serial.println(F("  SETADC,<k>       - Constante ADC"));
    Serial.println(F("  SETURL,<url>     - URL base"));
    Serial.println(F("  ESTADO           - Estado completo"));
    Serial.println(F("  LEERED           - Leer entradas"));
    Serial.println(F("  LEEVDC           - Leer voltaje"));
    Serial.println(F("  INIMDM,1         - Reiniciar Ethernet"));
    Serial.println(F("  RESETS           - Reset software"));
    Serial.println(F("  INIVAR           - Recargar config"));
    Serial.println(F("  RSTVAR           - Defaults fabrica"));
    Serial.println(F("  HELP             - Esta ayuda"));
}

uint8_t SerialParser::_splitParams(const char* str, char params[][CMD_MAX_LEN]) {
    uint8_t count = 0;
    char* token = strtok(const_cast<char*>(str), ",");
    while (token && count < CMD_MAX_PARAMS) {
        strncpy(params[count], token, CMD_MAX_LEN - 1);
        count++;
        token = strtok(nullptr, ",");
    }
    return count;
}

bool SerialParser::_parseIP(const char* str, uint8_t ip[4]) {
    int a, b, c, d;
    if (sscanf(str, "%d.%d.%d.%d", &a, &b, &c, &d) == 4) {
        if (a >= 0 && a <= 255 && b >= 0 && b <= 255 && 
            c >= 0 && c <= 255 && d >= 0 && d <= 255) {
            ip[0] = a; ip[1] = b; ip[2] = c; ip[3] = d;
            return true;
        }
    }
    return false;
}

bool SerialParser::_parseMAC(const char* str, uint8_t mac[6]) {
    int vals[6];
    if (sscanf(str, "%2x:%2x:%2x:%2x:%2x:%2x", 
               &vals[0], &vals[1], &vals[2], &vals[3], &vals[4], &vals[5]) == 6) {
        for (int i = 0; i < 6; i++) {
            if (vals[i] < 0 || vals[i] > 255) return false;
            mac[i] = vals[i];
        }
        return true;
    }
    if (strlen(str) == 12) {
        for (int i = 0; i < 6; i++) {
            char hex[3] = {str[i*2], str[i*2+1], 0};
            mac[i] = strtol(hex, nullptr, 16);
        }
        return true;
    }
    return false;
}