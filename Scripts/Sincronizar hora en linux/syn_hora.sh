#!/bin/bash

function sincronizar {

  # Variables.
  let proc=5
  s_null="/dev/null"
  RED=$(tput setaf 1)
  NORMAL=$(tput sgr0)
  GREEN=$(tput setaf 2)

  # Indicamos al usuario que comenzamos las tareas.
  echo
  echo "[Realizando tareas, espere un momento por favor (No cierre la terminal)...]"
  echo
  printf " - ${GREEN}Procesos restantes: ${NORMAL}"$proc
  echo

  # Tareas.
  #

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

  let "proc -= 1"
  echo
  printf " - ${GREEN}Procesos restantes: ${NORMAL}"$proc
  echo

  #
  # Obtenemos la ip por parametro

  echo
  echo "================================================================================"
  echo "      Comenzando la configuración de chronyc, debera introducir la ip "
  echo "                   Por favor no cierre la terminal..."
  echo "================================================================================"
  echo

  regex="^([0-9]{1,3})\.([0-9]{1,3})\.([0-9]{1,3})\.([0-9]{1,3})$"
  i=1

  while [ $i != 0 ]; do
    echo "Introduce la dirección IP del servidor NTP:"
    read IP
    # Comprobamos si la dirección IP cumple con el formato
    if [[ $IP =~ $regex ]]; then
      if [[ ${BASH_REMATCH[1]} -le 255 && ${BASH_REMATCH[2]} -le 255 && ${BASH_REMATCH[3]} -le 255 && ${BASH_REMATCH[4]} -le 255 ]]; then
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
            echo
            echo "No se encontro la linea de configuración, se procede a crearla."
            echo
            let "proc -= 1"
            #printf "%40s\n" "${GREEN}Procesos restantes: ${NORMAL}"$proc
            echo
            printf " - ${GREEN}Procesos restantes: ${NORMAL}"$proc
            echo

            #
          else

            # Si se encuentra la modifica
            echo
            echo "Se encontro configurado: $(grep -F "$cadena" "$archivo")"
            echo
            sudo sed -i "s/server.*/server $IP prefer iburst minpoll 4 maxpoll 4/g" $archivo
            echo "Se aplico correctamente la configuración para la IP:$IP"
            let "proc -= 1"
            echo
            printf " - ${GREEN}Procesos restantes: ${NORMAL}"$proc
            echo

            #
          fi

          # Reiniciar chrony para aplicar la configuración
          echo
          echo "Reiniciando el servicio de chronyd..."
          echo
          sudo systemctl restart chronyd
          echo
          echo "Reinicio terminado."
          echo
          let "proc -= 1"
          echo
          printf " - ${GREEN}Procesos restantes: ${NORMAL}"$proc
          echo

          #

          # Comprobar si se sincronizó correctamente con el servidor de tiempo
          echo
          echo "Comprobacion de sincronización..."
          echo
          chronyc sources -v
          let "proc -= 1"
          echo
          printf " - ${GREEN}Procesos restantes: ${NORMAL}"$proc
          echo

          #

          #if de verificacion ip
          #
          i=0
          break
        fi

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

  echo
  printf "${GREEN}[Tareas finalizadas con éxito]${NORMAL}"

  echo
  # Liberamos Variables.
  proc=
  s_null=
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
