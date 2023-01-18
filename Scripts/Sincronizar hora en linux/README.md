# Sincronizar hora en linux

_Este script se encarga de descargar la herramienta chrony independientemente de la distribución de linux, y posteriormente se le debera pasar una ip para que realice la configuración del servidor NTP de forma automatica._

## Comenzando 🚀

_Estas breves instrucciones te permitirán realizar un correcto funcionamiento en tu máquina local para propósitos de desarrollo y pruebas._

### Pre-requisitos 📋

_¿Que cosas necesitas para sincronizar correctamente?_

```
Conexión a internet y un servidor NTP
```

### Ejecución ⚙️

_Simplemente debes de clonar la carpeta del repositorio a la maquina que quieras sincronizar_

_Ejemplo_

```
git clone https://github.com/BrianTuduri/Linux.git
```

_Luego ubiado dentro de la carpeta "Sincronizar hora en linux" deberas ejecutar con bash y permisos de super usuario el script_

```
sudo bash syn_hora.sh
```
_Comenzara la comprobación del paquete chronyc, en caso de no tenerlo instalado, este detectara tu distribución de Linux para instalar, en caso de que no se logre identificar, pedira instalar chrony manualmente._

_Luego de la comprobación o instalación exitosa del paquete chronyc, se pedira introducir la dirección IP del servidor NTP._

_Finalmente se puede visualizar en consola, el estado de la sincronización para comprobar si esta se encuentra correcta._

## Autor ✒️

* **Brian Tuduri** - *Script* - [BrianTuduri](https://github.com/BrianTuduri)
