#pragma once

#include "DITECNETMQTT.h"

class SerialParser {
public:
    static void init();
    static void process();
    static void printHelp();
    
private:
    static char _buffer[SERIAL_BUFFER_SIZE];
    static uint16_t _buffer_pos;
    static ParsedCommand_t _parseCommand(const char* cmd);
    static void _executeCommand(const ParsedCommand_t& parsed);
    static void _sendResponse(const char* msg);
    static uint8_t _splitParams(const char* str, char params[][CMD_MAX_LEN]);
    static bool _parseIP(const char* str, uint8_t ip[4]);
    static bool _parseMAC(const char* str, uint8_t mac[6]);
};

extern SerialParser SerialCmd;