#!/bin/bash
# Autora: Ana Reyes
# Fecha: 13 - 09 - 2024
# AI_2024_list.sh - Script para listar información de archivos basado en ciertos parámetros.
# El script acepta los siguientes parámetros:
# -s: Especificar un archivo para obtener información detallada.
# -g: Listar los 3 archivos más grandes en un directorio.
# -p: Listar los 3 archivos más pequeños en un directorio.
# -x: Mostrar solo archivos ejecutables (se puede combinar con -g o -p).

# Limpiar la pantalla
clear

# Colores para el texto usando secuencias de escape
nada='\033[00m'    # Sin color (por defecto)
rojo='\033[01;31m' # Rojo para mensajes de error
negrita='\033[1m'  # Negrita para destacar textos
verde='\033[1;32m'  # Verde para mostrar el uso correcto

# Función para mostrar el uso del script en caso de uso incorrecto
mostrar_uso() {
  echo -e "${verde}Uso: $0 [-s archivo] [-g] [-p] [-x] [ruta]${nada}"
  echo "  -s archivo   Especificar archivo para mostrar detalles."
  echo "  -g           Listar los 3 archivos más grandes."
  echo "  -p           Listar los 3 archivos más pequeños."
  echo "  -x           Mostrar solo archivos ejecutables."
  exit 1
}

# Verificar si no se han pasado parámetros al script
if [ $# -eq 0 ]; then
  # Si no se han proporcionado parámetros, muestra un mensaje de error y la ayuda del uso del script
  echo -e "${rojo}ERROR:${nada} No te olvides de pasar un parametro! :)"
  mostrar_uso
fi

# Función para obtener información detallada de un archivo específico
info_archivo() {
  archivo=$1
  # Verifica si el archivo es un directorio, lo cual es inválido para la opción -s
  if [ -d "$archivo" ]; then
    echo -e "${rojo}ERROR:${nada} El parámetro -s solo acepta archivos, no directorios."
    mostrar_uso
  fi
  # Verifica si el archivo no existe
  if [ ! -f "$archivo" ]; then
    echo -e "${rojo}ERROR:${nada} El archivo ${negrita}$archivo${nada} no existe."
    echo -e Verifique la ${negrita}ruta${nada} o el ${negrita}nombre${nada} del archivo.
    mostrar_uso
  fi
  # Si el archivo existe, obtiene y muestra su información: nombre, tamaño, dueño y permisos
  nombre=$(basename "$archivo")
  tamano=$(du -h "$archivo" | cut -f1)
  dueno=$(ls -l "$archivo" | awk '{print $3}')
  permisos=$(ls -l "$archivo" | awk '{print $1}')
  echo -e "${negrita}Nombre:${nada} $nombre"
  echo -e "${negrita}Tamaño:${nada} $tamano"
  echo -e "${negrita}Dueño:${nada} $dueno"
  echo -e "${negrita}Permisos:${nada} $permisos"
}

# Función para listar archivos en formato de tabla
listar_archivos() {
  directorio=$1
  cantidad=$2
  filtro=$3

  # Verifica si el argumento proporcionado es un archivo en lugar de un directorio
  if [ -f "$directorio" ]; then
    echo -e "${rojo}ERROR:${nada} Los parámetros -g, -p y -x solo aceptan directorios, no archivos."
    mostrar_uso
  fi
  # Verifica si el directorio no existe
  if [ ! -d "$directorio" ]; then
    echo -e "${rojo}ERROR:${nada} La ruta: ${negrita}$directorio${nada} no existe."
    echo -e Verifique la ${negrita}ruta${nada}.
    mostrar_uso
  fi

  # Si se solicitó mostrar solo archivos ejecutables, aplica un filtro adicional en el comando find
  if [ "$filtro" = "ejecutables" ]; then
    archivos=$(find "$directorio" -maxdepth 1 -type f -executable -printf "%s %p\n")
  else
    archivos=$(find "$directorio" -maxdepth 1 -type f -printf "%s %p\n")
  fi

  # Ordena los archivos por tamaño si se solicitan los más grandes o los más pequeños
  if [ -n "$archivos" ]; then
    if [ "$modo" = "grandes" ]; then
      archivos=$(echo "$archivos" | sort -nr | head -n "$cantidad")
    elif [ "$modo" = "pequenos" ]; then
      archivos=$(echo "$archivos" | sort -n | head -n "$cantidad")
    fi
  fi

  # Imprime los encabezados de la tabla con tamaño, nombre, dueño y permisos
  printf "%-10s %-40s %-10s %-10s\n" "Tamaño" "Nombre" "Dueño" "Permisos"
  echo -e ${negrita}------------------------------------------------------------------------${nada}

  # Recorre los archivos obtenidos e imprime la información formateada
  echo "$archivos" | while read -r tamano nombre; do
    if [ -z "$tamano" ] || [ -z "$nombre" ]; then
      continue
    fi
    dueno=$(ls -l "$nombre" | awk '{print $3}')
    permisos=$(ls -l "$nombre" | awk '{print $1}')
    nombre=$(basename "$nombre")
    tamano=$(numfmt --to=iec "$tamano")
    printf "%-10s %-40s %-10s %-10s\n" "$tamano" "$nombre" "$dueno" "$permisos"
  done
}

# Variables predeterminadas para la ruta y los modos de operación
ruta="."
modo=""
filtro=""

i=1
opciones_contadas=0

# Bucle para procesar los argumentos pasados al script
while [ "$i" -le "$#" ]; do
  arg=${!i}
  
  # Verifica el tipo de argumento que es y actúa en consecuencia
  case "$arg" in
    -s)
      # Verifica que la opción -s esté sola y no combinada con otras opciones
      if [ "$i" -ne 1 ]; then
        echo -e "${rojo}ERROR:${nada} La opción -s no puede combinarse con otras opciones."
        mostrar_uso
      fi
      i=$((i + 1))
      archivo=${!i}
      # Verifica si no se proporcionó un archivo después de -s
      if [ -z "$archivo" ]; then
        echo -e "${rojo}ERROR:${nada} Debe proporcionar un archivo después de -s."
        mostrar_uso
      fi
      info_archivo "$archivo"
      exit 0
      ;;
    -g)
      # Verifica que no se usen las opciones -g y -p juntas
      if [ "$modo" = "pequenos" ]; then
        echo -e "${rojo}ERROR:${nada} No se pueden usar -g y -p al mismo tiempo."
        mostrar_uso
      fi
      modo="grandes"
      opciones_contadas=$((opciones_contadas + 1))
      ;;
    -p)
      # Verifica que no se usen las opciones -g y -p juntas
      if [ "$modo" = "grandes" ]; then
        echo -e "${rojo}ERROR:${nada} No se pueden usar las opciones -g y -p al mismo tiempo."
        mostrar_uso
      fi
      modo="pequenos"
      opciones_contadas=$((opciones_contadas + 1))
      ;;
    -x)
      filtro="ejecutables"
      opciones_contadas=$((opciones_contadas + 1))
      ;;
    *)
      # Asigna la ruta si el argumento no es una opción reconocida
      if [[ "$arg" != -* ]]; then
        ruta="$arg"
      else
        echo -e "${rojo}ERROR:${nada} El parámetro '${negrita}$arg${nada}' no es válido."
        mostrar_uso
      fi
      ;;
  esac
  i=$((i + 1))
done

# Verifica que no se hayan pasado más de dos opciones al mismo tiempo
if [ "$opciones_contadas" -gt 2 ]; then
  echo -e "${rojo}ERROR:${nada} Solo se permiten hasta 2 parámetros de opción al mismo tiempo."
  mostrar_uso
fi

# Llama a la función de listar archivos, pasando la ruta y el modo si se ha definido
if [ "$modo" = "grandes" ] || [ "$modo" = "pequenos" ]; then
  listar_archivos "$ruta" 3 "$filtro"
else
  listar_archivos "$ruta" 0 "$filtro"
fi
