#!/bin/bash

function sincronizar {

  echo "================================================================================"
  echo "      Comenzando la comprobación del paquete chronyc "
  echo "                   Por favor no cierre la terminal..."
  echo "================================================================================"
  echo

  # Verificar si chrony está instalado
  if ! [ -x "$(command chronyc -v)" ]; then
    # Instalar chrony de acuerdo a la distribución de Linux
    if [ -f /etc/redhat-release ]; then
      # Distribuciones Red Hat, CentOS, Fedora
      yum install chrony
    elif [ -f /etc/lsb-release ]; then
      # Distribuciones Ubuntu, Debian
      apt-get install chrony
    elif [ -f /etc/arch-release ]; then
      # Distribución Arch Linux
      pacman -S chrony
    else
      # Otras distribuciones de Linux
      echo "No se pudo detectar tu distribución de Linux. Por favor, instala chrony manualmente."
      exit 1
    fi
  fi

  # Obtenemos la ip por parametro

  echo
  echo "================================================================================"
  echo "      Comenzando la configuracion de chronyc, debera introducir la ip "
  echo "                   Por favor no cierre la terminal..."
  echo "================================================================================"
  echo
  echo "Introduce la dirección IP del servidor NTP:"
  read IP

  regex="^([0-9]{1,3})\.([0-9]{1,3})\.([0-9]{1,3})\.([0-9]{1,3})$"
  i=1

  while [ $i -ne 0 ]; do

    # Comprobamos si la dirección IP cumple con el formato
    if [[ $IP =~ $regex ]]; then
      if [[ ${BASH_REMATCH[1]} -le 255 && ${BASH_REMATCH[2]} -le 255 && ${BASH_REMATCH[3]} -le 255 && ${BASH_REMATCH[4]} -le 255 ]]; then
        echo "La dirección IP es válida"
        #La dirección IP es valida
        if [ -z "$IP" ]; then

          # No se ingresa un valor como direccion ip.
          echo "\$ERROR: No se ingreso ningun valor"
        else
          # Se ingresa un valor

          # Configurar chrony para utilizar la IP del servidor de tiempo
          archivo="/etc/chrony.conf"
          cadena="server"

          # Verificamos si ya se encuentra una config de server

          if ! grep -F "$cadena" "$archivo"; then

            # Si no se encuentra, agrega la linea de configuracion
            echo "$cadena" >>"$archivo"
            echo "No se encontro la linea de configuración, se procede a crearla"
          else

            # Si se encuentra la modifica
            echo "Se encontro configurado: $(grep -F "$cadena" "$archivo")"
            sudo sed -i "s/server.*/server $IP prefer iburst minpoll 4 maxpoll 4/g" $archivo
            echo "Se aplico correctamente la configuración para la IP:$IP."
          fi

          # Reiniciar chrony para aplicar la configuración
          echo "Reiniciando el servicio de chronyd..."
          sudo systemctl restart chronyd
          echo "Reinicio terminado"

          # Comprobar si se sincronizó correctamente con el servidor de tiempo
          echo "Comprobacion de sincronización..."
          chronyc sources -v

        #if de verificacion ip
        fi
        #
        i=0
        break
      else
        printf "Error: %s\n" "la dirección ip excede el rango." 1>&2
        i=$((i + 1))
      fi
    else
      printf "Error: %s\n" "la ip no tiene el formato correcto." 1>&2
      i=$((i + 1))
    fi
    if [ $i -eq 0 ]; then
      break
    fi
  done

}

if [ "$(id -u)" != "0" ]; then
  echo
  echo "============================================================================"
  echo "¡Este Script debe ejecutarse como SuperUsuario!" 1>&2
  echo "============================================================================"
  echo
  exit 1
else
  sincronizar
  exit 1
fi
