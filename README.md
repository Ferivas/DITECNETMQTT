# DITECNETMQTT

Implementacion de un equipo de monitoreo de entradas digitales y un sensor de temperatura basado en el ATMEGA1284P y el módulo EThernet WIZ820io.

---

## Operacion anterior

El equipo esta programado en BASCOM AVR y envia los datos de las señales de las entradas digitales y el sensor de temperatura hacia Thingsboard (thongsboard.cloud) utilizando POST HTTP REST API.

## Nueva operacion
Es necesario modificar el programa para que trabaje igual al de BASCOM pero codificando con Platformio en un entorno Arduino. Ya no se quiere trabajar con POST HTTP, sino más bien con MQTT.

