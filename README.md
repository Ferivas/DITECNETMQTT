# DITECNETMQTT

Implementación de un equipo de monitoreo de entradas digitales y sensor de temperatura basado en el ATMEGA1284P y el módulo Ethernet WIZ820io (W5200).

## Descripción

Este proyecto migra el firmware original escrito en BASCOM AVR (que usaba HTTP POST REST API hacia Thingsboard) a un entorno **PlatformIO + Arduino framework**, cambiando la comunicación a **MQTT** hacia **Thingsboard Cloud**.

---

## Hardware

| Componente | Pin / Conexión |
|------------|----------------|
| MCU | ATMEGA1284P @ 7.3728 MHz |
| Ethernet | WIZ820io (W5200) SPI: CS=PB3, RST=PB2 |
| LED Status | PB0 |
| Entradas digitales (6) | PC0-PC5 (pull-up interno) |
| DS18B20 (1-Wire) | PC5 (compartido con ED5) |
| ADC Voltaje | PA2 (ADC2) |
| Bootloader | Optiboot 115200 |

**Configuración de red por defecto:**
- IP estática: `192.168.0.57`
- Gateway: `192.168.0.1`
- Máscara: `255.255.255.0`
- MAC: `00:08:DC:01:01:22`

---

## Estructura del Proyecto

```
DITECNETMQTT/
├── platformio.ini              # Configuración PlatformIO
├── .gitignore                  # Archivos a ignorar en git
├── README.md                   # Este archivo
├── include/
│   └── DITECNETMQTT.h         # Definiciones globales, pins, structs
├── src/
│   ├── main.cpp               # Setup + loop principal
│   ├── Config.h/.cpp          # Gestión EEPROM (magic 0xD1EC0000)
│   ├── EthernetManager.h/.cpp # Driver W5200 (Ethernet_Generic)
│   ├── MQTTHandler.h/.cpp     # Cliente MQTT Thingsboard (PubSubClient)
│   ├── DigitalInputs.h/.cpp   # 6 ED máquina de estados 10Hz
│   ├── TemperatureSensor.h/.cpp # DS18B20 1-Wire
│   ├── VoltageMonitor.h/.cpp  # ADC voltaje (4 muestras, K=0.004297432)
│   ├── Telemetry.h/.cpp       # JSON Thingsboard, buffer circular 16
│   ├── LedStatus.h/.cpp       # LED PB0, 16 patrones BASCOM
│   └── SerialParser.h/.cpp    # 26 comandos serie compatibles BASCOM
└── lib/                        # Librerías locales (si aplica)
```

---

## Características de la Implementación

### Comunicación MQTT (Thingsboard)
- **Broker**: `thingsboard.cloud:1883` (plano, sin TLS)
- **Autenticación**: Token de dispositivo (default: `eljtyKCqdobh2MDSXbPa`)
- **Topic telemetría**: `v1/devices/me/telemetry`
- **Formato JSON**:
```json
{
  "values": {
    "pt1": 0, "pt2": 1, "ac1": 0, "tvs": 1,
    "pwr": 12.45, "t1": 23.50,
    "cini": 5, "cinimdc": 2
  }
}
```
- **Reconexión automática** cada 5s si se pierde conexión
- **Keepalive**: 60s

### Entradas Digitales (6 canales)
- Muestreo a **10Hz** (cada 100ms) via `millis()`
- **Máquina de estados** por canal (igual que BASCOM):
  - `0: NORMAL` (estable en 0)
  - `1: ALARMA` (estable en 1)
  - `2: PRE-ALARMA` (transición 0→1, contando Tredmas)
  - `3: PRE-NORMAL` (transición 1→0, contando Tredmenos)
- **Debouncing configurable**: `Tredmas[]` y `Tredmenos[]` (default 20 = 2s, ED3=50 = 5s)
- **Polaridad invertible** por canal (`Edpol`)
- **Habilitación individual** (`Edhab`, default ED0 y ED2)
- **Eventos en flanco** generan telemetría inmediata + envío periódico

### Sensor de Temperatura (DS18B20)
- Bus 1-Wire en **PC5** (parasitic/normal)
- Resolución 12 bits, conversión no bloqueante
- Lectura cada **5s**
- CRC check, reintento automático

### Monitor de Voltaje (ADC)
- Canal **ADC2 (PA2)**
- Promedio de **4 muestras** cada 5s
- Factor de calibración `K = 0.004297432` (ajustable por `SETADC`)

### Telemetría
- **Buffer circular de 16 slots** (FIFO)
- Envío por **evento** (flanco ED) + **periódico** (4 slots configurables)
- **Slots automáticos** (`autoval[4]`, `offset[4]`):
  - Slot 1: 300s (5 min), offset 0
  - Slot 2: 43200s (12h), offset 120s
  - Slot 3: 43200s (12h), offset 30s
  - Slot 4: 7200s (2h), offset 60s

### LED Status (PB0)
- 16 patrones de 32 bits (replicados de `Tabla_estado` BASCOM)
- Patrón 1 por defecto (heartbeat lento)

### Persistencia EEPROM
- Estructura `Config_t` con **magic number 0xD1EC0000**
- Validación al arranque, carga defaults si inválido
- Contadores persistentes: `cntrini` (reinicios), `cntrinimdc` (reinicios Ethernet)

### Watchdog
- **WDTO_8S** habilitado en loop principal
- Reset por software via comando `RESETS`

---

## Comandos Serie (115200 8N1)

Formato: `COMANDO,param1,param2,...` → Respuesta: `WATCHING INFORMA. ...` o `$OK` / `$ERRORn`

| Comando | Parámetros | Descripción |
|---------|------------|-------------|
| `LEEVFW` | - | Versión firmware |
| `LEERID` | - | ID serial del chip |
| `SETIPX` | `<ip>` | IP servidor MQTT |
| `SETPTX` | `<puerto>` | Puerto MQTT (default 1883) |
| `LEEIPX` | - | Leer IP servidor |
| `LEEPTX` | - | Leer puerto MQTT |
| `SETKTB` | `<token>` | Token Thingsboard |
| `LEEKTB` | - | Leer token |
| `SETBUG` | `<0-2>` | Nivel debug |
| `LEEBUG` | - | Leer debug |
| `SETADC` | `<k>` | Constante ADC |
| `LEEADC` | - | Leer K ADC |
| `LEEVDC` | - | Leer voltaje |
| `SETAUT` | `<1-4>,<seg>` | Periodo envío automático |
| `SETOFF` | `<1-4>,<seg>` | Offset envío automático |
| `LEEAUT` | `<1-4>` | Leer periodo auto |
| `LEEOFF` | `<1-4>` | Leer offset auto |
| `SETNEW` | `<1-4>` | Forzar envío slot auto |
| `SETINI` | `<valor>` | Contador reinicios |
| `LEEINI` | - | Leer contador reinicios |
| `SETINM` | `<valor>` | Contador reinicios Ethernet |
| `LEEINM` | - | Leer contador Ethernet |
| `ESTADO` | - | Estado completo (EDs, voltaje, temp) |
| `LEERED` | - | Leer 4 primeras EDs |
| `INIMDM` | `<0/1>` | 1=Reiniciar Ethernet+MQTT |
| `RESETS` | - | Reset por software |
| `INIVAR` | - | Recargar config EEPROM |
| `RSTVAR` | - | Valores de fábrica |
| `SETHAB` | `<1-6>,<0/1>` | Habilitar ED |
| `LEEHAB` | - | Leer habilitación EDs |
| `SETNET` | `<1-4>,<valor>` | 1=IP, 2=GW, 3=Mask, 4=MAC |
| `LEENET` | `<1-4>` | Leer config red |
| `SETPOL` | `<1-6>,<0/1>` | Polaridad ED |
| `LEEPOL` | - | Leer polaridades |
| `SETPAR` | `1,<1-6>,<1-4>,<val>` | Params ED: 1=nombre, 2=pol, 3=T+, 4=T- |
| `LEEPAR` | `1,<1-6>` | Leer params ED |
| `SETURL` | `<url>` | URL base (compatibilidad) |
| `LEEURL` | - | Leer URL |
| `HELP` | - | Lista de comandos |

**Ejemplos:**
```
SETKTB,eljtyKCqdobh2MDSXbPa
SETNET,1,192.168.1.100
SETNET,4,0008DC010122
SETAUT,1,300
SETHAB,3,1
SETPAR,1,3,2,1
ESTADO
```

---

## Compilación y Programación

### Requisitos
- PlatformIO Core/IDE
- Python 3.x

### Compilar
```bash
pio run
```

### Programar (avrdude)
```bash
# Desde PlatformIO (usa config del .ini)
pio run -t upload

# Manual con avrdude (ajustar puerto si es necesario)
avrdude -v -p atmega1284p -c arduino -b 115200 -D -P /dev/ttyUSB0 -U flash:w:.pio/build/ditecnetmqtt/firmware.hex:i
```

**Parámetros avrdude:**
| Opción | Valor |
|--------|-------|
| `-p` | atmega1284p |
| `-c` | arduino (Optiboot) |
| `-b` | 115200 |
| `-P` | /dev/ttyUSB0 (o tu puerto) |
| `-U` | flash:w:firmware.hex:i |

### Monitor Serie
```bash
pio device monitor
# o manual
screen /dev/ttyUSB0 115200
```

---

## Configuración PlatformIO (platformio.ini)

```ini
[env:ditecnetmqtt]
platform = atmelavr
board = ATmega1284P
framework = arduino
board_build.f_cpu = 7372800L
upload_protocol = arduino
upload_speed = 115200
monitor_speed = 115200
lib_deps = 
    khoih-prog/Ethernet_Generic@^2.8.1
    knolleary/PubSubClient@^2.8
    paulstoffregen/OneWire@^2.3.8
    milesburton/DallasTemperature@^3.11.0
    bblanchon/ArduinoJson@^7.0.0
build_flags = 
    -D F_CPU=7372800UL
    -D BAUD_RATE=115200
    -D ARDUINO_ARCH_AVR
    -D ETHERNET_USE_W5200
    -D ETHERNET_LARGE_BUFFERS
```

---

## Uso de Memoria (compilación release)

| Memoria | Uso | Disponible | % |
|---------|-----|------------|---|
| **Flash** | 43,886 bytes | 131,072 bytes | 33.5% |
| **RAM** | 4,148 bytes | 16,384 bytes | 25.3% |

---

## Migración desde BASCOM

| BASCOM | Arduino/PlatformIO |
|--------|-------------------|
| HTTP POST REST | MQTT (PubSubClient) |
| `Config Tcpip` estático | `Ethernet.begin(mac, ip, gw, mask)` |
| `Wiz5100_sendit` manual | `EthernetClient` + `PubSubClient` |
| Timer0/1 interrupciones | `millis()` + polling 10Hz |
| `1wreset`/`1wwrite` | `OneWire` + `DallasTemperature` |
| `Getadc(2)` | `analogRead(PA2)` + promedio |
| EEPROM `Eram` | `EEPROM.put/get()` |
| `Print #1` debug | `Serial.print()` |

---

## Licencia

Desarrollado por **WATCHING Soluciones Tecnológicas** - Fernando Vázquez