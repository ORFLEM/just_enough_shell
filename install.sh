#!/usr/bin/env bash

# Installation for my configs

# variables
BACKUP_DIR="$HOME/Your_old_configs"
CONFIG_DIR="$HOME/.config"

# installation script

# warnings 
ru_warning() {
  echo "ВНИМАНИЕ: дальше будут СОХРАНЕНЫ И ПЕРЕЗАПИСАНЫ ваши конфигурации!! Вы уверены?"
  read -p "  Прошу укажите ваше решение [да|yes|нет|no]:  " shure
  shure=$(echo "$shure" | tr '[:upper:]' '[:lower:]')
  case $shure in
    да|д|yes|y)
      echo ""
      echo "Принято, сейчас будут созданы сохранения и перезаписаны нынешние"
      sleep 3
      ;;
    нет|н|no|n)
      echo ""
      echo "Принято, остановка скрипта, доброго дня вам)"
      exit 0
      ;;
  esac
}

en_warning() {
  echo "WARNING: Your configurations will be SAVED and OVERWRITTEN!! Are you sure?"
  read -p " Please specify your decision [yes|no]: " shure
  shure=$(echo "$shure" | tr '[:upper:]' '[:lower:]')
  case $shure in
    yes|ye|y)
      echo ""
      echo "Accepted, now creating backups and overwriting current configurations"
      sleep 3
      ;;
    no|n)
      echo ""
      echo "Accepted, stopping script. Have a nice day)"
      exit 0
      ;;
  esac
}

# creating backups
ru_back() {
  echo ""
  if ! sudo -v; then
    echo "Требуются права sudo"
    exit 1
  fi
  echo "Создание сохранений:"

  if ! mkdir -p "$BACKUP_DIR"; then
        echo "ОШИБКА: не удалось создать директорию бэкапов"
        exit 1
  fi
  
  echo "  Создание сохранения конфигурации NixOS"
  sudo cp -r /etc/nixos "$BACKUP_DIR/nixos-$(date +%Y.%m.%d-%H:%M:%S)"

  echo "  Создание сохранения директории конфигураций пользователя"
  cp -r "$CONFIG_DIR" "$BACKUP_DIR/configs-$(date +%Y.%m.%d-%H:%M:%S)"

  echo "  Создание сохранения конфигурации bash"
  cp "$HOME/.bashrc" "$BACKUP_DIR/bashrc-$(date +%Y.%m.%d-%H:%M:%S)"
  [ -f "$HOME/.bash_profile" ] && cp "$HOME/.bash_profile" "$BACKUP_DIR/bash_profile-$(date +%Y.%m.%d-%H:%M:%S)"
}

en_back() {
  echo ""
  echo "Creating backups, sudo privileges required"

  if ! mkdir -p "$BACKUP_DIR"; then
        echo "ERROR: can't create backup directory"
        exit 1
  fi

  echo " Creating NixOS configuration backup"
  sudo cp -r /etc/nixos "$BACKUP_DIR/nixos-$(date +%Y.%m.%d-%H:%M:%S)"

  echo " Creating user configs directory backup"
  cp -r "$CONFIG_DIR" "$BACKUP_DIR/configs-$(date +%Y.%m.%d-%H:%M:%S)"

  echo " Creating bash configuration backup"
  cp "$HOME/.bashrc" "$BACKUP_DIR/bashrc-$(date +%Y.%m.%d-%H:%M:%S)"
  [ -f "$HOME/.bash_profile" ] && cp "$HOME/.bash_profile" "$BACKUP_DIR/bash_profile-$(date +%Y.%m.%d-%H:%M:%S)"
}

# rewrite configs
ru_install () {
  echo ""
  echo "Установка JES:"
  for item in ".local" ".config" ".cache" ".bashrc" ".bash_profile" "flake.nix" "configuration.nix"; do
    echo -ne "\r проверка наличия файлов.  "
    sleep 0.15
    echo -ne "\r проверка наличия файлов.. "
    sleep 0.15
    echo -ne "\r проверка наличия файлов..."
    sleep 0.15
    echo -ne "\r проверка наличия файлов .."
    sleep 0.15
    echo -ne "\r проверка наличия файлов  ."
    sleep 0.15
    echo -ne "\r проверка наличия файлов   "
    sleep 0.15
      if [ ! -e "./$item" ]; then
          echo "ОШИБКА: файл/директория ./$item не найдены"
          exit 1
      fi
  done

  echo -ne "\r  установка файлов .local \n  [#--------------]"
  cp -r ./.local/ ~/.local/
  sleep 1
  echo -ne "\r  установка файлов .config \n  [##-------------]"
  cp -r ./.config/ ~/.config/
  sleep 1
  echo -ne "\r  установка файлов .cache \n  [###------------]"
  cp -r ./.cache/ ~/.cache/
  sleep 1
  echo -ne "\r  установка файлов .bash \n  [####-----------]"
  cp ./.bashrc ~/
  sleep 1
  echo -ne "\r  [#####----------]"
  cp ./.bash_profile ~/
  sleep 1
  echo -ne "\r  установка файлов NixOS \n  [######---------]"
  sudo cp ./flake.nix /etc/nixos/
  sleep 1
  echo -ne "\r  [#######--------]"
  USERNAME=$(grep 'users.users.' /etc/nixos/configuration.nix | awk -F '.' '{print $3}' | awk -F ' ' '{print $1}')
  sleep 1
  echo -ne "\r  [########------]"
  TIMEZONE=$(grep 'time.timeZone' /etc/nixos/configuration.nix | awk -F ' ' '{print $3}' | cut -d '"' -f 2)
  sleep 1
  echo -ne "\r  [#########-----]"
  PREFERED_WM=sway
  HOSTNAME=${HOSTNAME:-$(hostname)}
  sleep 1
  echo -ne "\r  [##########----]"
  GPU=amd
  ROCM=11.0.0
  THEME=zenburn
  sleep 1
  echo -ne "\r  [###########----]"
  USER_DESCRIPTION=$(awk -v usr="$USERNAME" '$0 ~ "users.users." usr {in_block=1} in_block && /description/ {print $0; exit} in_block && /};/ {exit}' /etc/nixos/configuration.nix | cut -d '"' -f 2)
  echo -ne "\r  Проверьте данные: \n"
  echo "    username = $USERNAME"
  echo "    hostname = $HOSTNAME"
  echo "    timezone = $TIMEZONE"
  echo "    description = $USER_DESCRIPTION"
  read -p "  [да|yes|нет|no]:  " shure
  shure=$(echo "$shure" | tr '[:upper:]' '[:lower:]')
  case $shure in
    да|д|yes|ye|y)
      echo ""
      read -p "  Введите предпочитаемый WM [$PREFERED_WM]: " input_wm
      [ -n "$input_wm" ] && PREFERED_WM=$input_wm
      
      read -p "  Введите производителя чипа видеокарты [$GPU]: " input_gpu
      [ -n "$input_gpu" ] && GPU=$input_gpu
      
      if [[ $GPU == "amd" ]]; then
        read -p "  Введите подходящую версию ROCM [$ROCM]: " input_rocm
        [ -n "$input_rocm" ] && ROCM=$input_rocm
      fi
      echo ""
      repeat=0
      while [ $repeat -lt 4 ]; do
        echo -ne "\033[F\r  Принято, генерируем конфиг.  \n  [###########----]"
        sleep 0.15
        echo -ne "\033[F\r  Принято, генерируем конфиг.. \n  [###########----]"
        sleep 0.15
        echo -ne "\033[F\r  Принято, генерируем конфиг...\n  [###########----]"
        sleep 0.15
        echo -ne "\033[F\r  Принято, генерируем конфиг ..\n  [############---]"
        sleep 0.15
        echo -ne "\033[F\r  Принято, генерируем конфиг  .\n  [############---]"
        sleep 0.15
        echo -ne "\033[F\r  Принято, генерируем конфиг   \n  [############---]"
        sleep 0.15
        repeat=$((repeat + 1))
      done
      ;;
      
    нет|н|no|n)
      echo -e "\n  Режим ручного ввода данных:"
      
      # Запрашиваем имя пользователя. Если нажать Enter, останется старое.
      read -p "  Введите username [$USERNAME]: " input_user
      [ -n "$input_user" ] && USERNAME=$input_user
      
      # Запрашиваем имя хоста.
      read -p "  Введите hostname [$HOSTNAME]: " input_host
      [ -n "$input_host" ] && HOSTNAME=$input_host
      
      # Запрашиваем часовой пояс.
      read -p "  Введите timezone [$TIMEZONE]: " input_zone
      [ -n "$input_zone" ] && TIMEZONE=$input_zone
      
      # Запрашиваем описание.
      read -p "  Введите description [$USER_DESCRIPTION]: " input_desc
      [ -n "$input_desc" ] && USER_DESCRIPTION=$input_desc

      read -p "  Введите предпочитаемый WM [$PREFERED_WM]: " input_wm
      [ -n "$input_wm" ] && PREFERED_WM=$input_wm

      read -p "  Введите производителя чипа видеокарты [$GPU]: " input_gpu
      [ -n "$input_gpu" ] && GPU=$input_gpu

      if [[ $GPU == "amd" ]]; then
        read -p "  Введите подходящую версию ROCM [$ROCM]: " input_rocm
        [ -n "$input_rocm" ] && ROCM=$input_rocm
      fi
    
      echo -e "\n  Данные успешно обновлены вручную!"
      repeat=0
      while [ $repeat -lt 4 ]; do
        echo -ne "\033[F\r  Принято, генерируем конфиг.  \n  [###########----]"
        sleep 0.15
        echo -ne "\033[F\r  Принято, генерируем конфиг.. \n  [###########----]"
        sleep 0.15
        echo -ne "\033[F\r  Принято, генерируем конфиг...\n  [###########----]"
        sleep 0.15
        echo -ne "\033[F\r  Принято, генерируем конфиг ..\n  [############---]"
        sleep 0.15
        echo -ne "\033[F\r  Принято, генерируем конфиг  .\n  [############---]"
        sleep 0.15
        echo -ne "\033[F\r  Принято, генерируем конфиг   \n  [############---]"
        sleep 0.15
        repeat=$((repeat + 1))
      done
      ;;
  esac
  sudo tee /etc/nixos/user-config.toml > /dev/null << EOF
hostname = "$HOSTNAME"
username = "$USERNAME"
description = "$USER_DESCRIPTION"
timezone = "$TIMEZONE"
preferred_wm = "$PREFERED_WM"
theme = "$THEME"

gpu = "$GPU"
rocm_version = "$ROCM"
EOF
  echo "  Конфиг успешно создан!"
  echo ""
  echo -ne "\r  генерация flake.lock\n  [#############--]"
  sleep 1
  cp ./configuration.nix /etc/nixos/
  cd /etc/nixos || { echo "  [ERROR] Не удалось перейти в /etc/nixos"; exit 1; }
  if ! sudo nix flake update --extra-experimental-features "nix-command flakes"; then
    echo "  [ERROR] Ошибка обновления flake.lock: установка преостановлена, проверьте /etc/nixos/flake.nix + другие файлы в /etc/nixos и запустите сборку flake и системы вручную, а после перезапустите ПК."
    exit 1
  fi
  cd ~/
  echo ""
  echo -ne "\r  проверка файлов  \n  [##############-]"
  sleep 1
  if [[ -f /etc/nixos/configuration.nix && -f /etc/nixos/flake.nix && -f /etc/nixos/flake.lock && -f /etc/nixos/user-config.toml && -f /etc/nixos/hardware-configuration.nix ]]; then
    echo "  Сборка системы:"
    if sudo nixos-rebuild switch; then
      echo "  сборка закончена! перезапустите ПК)"
      exit 0
    else
      echo "  [ERROR] Ошибка сборки! Проверьте сборку вручную."
      exit 1
    fi
  else
    echo "  [ERROR] Ошибка генерации: установка преостановлена, проверьте /etc/nixos и запустите сборку системы вручную, а после перезапустите ПК."
    exit 1
  fi
}

en_install () {
  echo ""
  echo "installing JES:"
  for item in ".local" ".config" ".cache" ".bashrc" ".bash_profile" "flake.nix" "configuration.nix"; do
    echo -ne "\r check files.  "
    sleep 0.15
    echo -ne "\r check files.. "
    sleep 0.15
    echo -ne "\r check files..."
    sleep 0.15
    echo -ne "\r check files .."
    sleep 0.15
    echo -ne "\r check files  ."
    sleep 0.15
    echo -ne "\r check files   "
    sleep 0.15
      if [ ! -e "./$item" ]; then
          echo "ERROR: file/directory ./$item not found"
          exit 1
      fi
  done

  echo -ne "\r  installing .local \n  [#--------------]"
  cp -r ./.local/ ~/.local/
  sleep 1
  echo -ne "\r  installing .config \n  [##-------------]"
  cp -r ./.config/ ~/.config/
  sleep 1
  echo -ne "\r  installing .cache \n  [###------------]"
  cp -r ./.cache/ ~/.cache/
  sleep 1
  echo -ne "\r  installing .bash \n  [####-----------]"
  cp ./.bashrc ~/
  sleep 1
  echo -ne "\r  [#####----------]"
  cp ./.bash_profile ~/
  sleep 1
  echo -ne "\r  installing NixOS configuration\n  [######---------]"
  sudo cp ./flake.nix /etc/nixos/
  sleep 1
  echo -ne "\r  [#######--------]"
  USERNAME=$(grep 'users.users.' /etc/nixos/configuration.nix | awk -F '.' '{print $3}' | awk -F ' ' '{print $1}')
  sleep 1
  echo -ne "\r  [########-------]"
  TIMEZONE=$(grep 'time.timeZone' /etc/nixos/configuration.nix | awk -F ' ' '{print $3}' | cut -d '"' -f 2)
  sleep 1
  echo -ne "\r  [#########------]"
  PREFERED_WM=sway
  HOSTNAME=${HOSTNAME:-$(hostname)}
  sleep 1
  echo -ne "\r  [##########----]"
  GPU=amd
  ROCM=11.0.0
  THEME=zenburn
  sleep 1
  echo -ne "\r  [###########----]"
  USER_DESCRIPTION=$(awk -v usr="$USERNAME" '$0 ~ "users.users." usr {in_block=1} in_block && /description/ {print $0; exit} in_block && /};/ {exit}' /etc/nixos/configuration.nix | cut -d '"' -f 2)
  echo -ne "\r  Check user's info: \n"
  echo "    username = $USERNAME"
  echo "    hostname = $HOSTNAME"
  echo "    timezone = $TIMEZONE"
  echo "    description = $USER_DESCRIPTION"
  read -p "  [yes|no]:  " shure
  shure=$(echo "$shure" | tr '[:upper:]' '[:lower:]')
  case $shure in
  yes|ye|y)
      echo ""
      read -p "  Write preferred WM [$PREFERED_WM]: " input_wm
      [ -n "$input_wm" ] && PREFERED_WM=$input_wm
      
      read -p "  Write your GPU [$GPU]: " input_gpu
      [ -n "$input_gpu" ] && GPU=$input_gpu
      
      if [[ $GPU == "amd" ]]; then
        read -p "  Write correct version ROCM for your GPU [$ROCM]: " input_rocm
        [ -n "$input_rocm" ] && ROCM=$input_rocm
      fi
    
      echo ""
      repeat=0
      while [ $repeat -lt 4 ]; do
        echo -ne "\033[F\r  OK, generating config.  \n  [###########----]"
        sleep 0.15
        echo -ne "\033[F\r  OK, generating config.. \n  [###########----]"
        sleep 0.15
        echo -ne "\033[F\r  OK, generating config...\n  [###########----]"
        sleep 0.15
        echo -ne "\033[F\r  OK, generating config ..\n  [############---]"
        sleep 0.15
        echo -ne "\033[F\r  OK, generating config  .\n  [############---]"
        sleep 0.15
        echo -ne "\033[F\r  OK, generating config   \n  [############---]"
        sleep 0.15
        repeat=$((repeat + 1))
      done
      ;;
      
    no|n)
      echo -e "\n  Mode - writing yourself info:"
      
      # Запрашиваем имя пользователя. Если нажать Enter, останется старое.
      read -p "  Write username [$USERNAME]: " input_user
      [ -n "$input_user" ] && USERNAME=$input_user
      
      # Запрашиваем имя хоста.
      read -p "  Write hostname [$HOSTNAME]: " input_host
      [ -n "$input_host" ] && HOSTNAME=$input_host
      
      # Запрашиваем часовой пояс.
      read -p "  Write timezone [$TIMEZONE]: " input_zone
      [ -n "$input_zone" ] && TIMEZONE=$input_zone
      
      # Запрашиваем описание.
      read -p "  Write description [$USER_DESCRIPTION]: " input_desc
      [ -n "$input_desc" ] && USER_DESCRIPTION=$input_desc

      read -p "  Write preferred WM [$PREFERED_WM]: " input_wm
      [ -n "$input_wm" ] && PREFERED_WM=$input_wm
      
      read -p "  Write your GPU [$GPU]: " input_gpu
      [ -n "$input_gpu" ] && GPU=$input_gpu
      
      if [[ $GPU == "amd" ]]; then
        read -p "  Write correct version ROCM for your GPU [$ROCM]: " input_rocm
        [ -n "$input_rocm" ] && ROCM=$input_rocm
      fi
      
      echo -e "\n  Info updated!"
      repeat=0
      while [ $repeat -lt 4 ]; do
        echo -ne "\033[F\r  Generating config.  \n  [###########----]"
        sleep 0.15
        echo -ne "\033[F\r  Generating config.. \n  [###########----]"
        sleep 0.15
        echo -ne "\033[F\r  Generating config...\n  [###########----]"
        sleep 0.15
        echo -ne "\033[F\r  Generating config ..\n  [############---]"
        sleep 0.15
        echo -ne "\033[F\r  Generating config  .\n  [############---]"
        sleep 0.15
        echo -ne "\033[F\r  Generating config   \n  [############---]"
        sleep 0.15
        repeat=$((repeat + 1))
      done
      ;;
  esac
  sudo tee /etc/nixos/user-config.toml > /dev/null << EOF
hostname = "$HOSTNAME"
username = "$USERNAME"
description = "$USER_DESCRIPTION"
timezone = "$TIMEZONE"
preferred_wm = "$PREFERED_WM"
theme = "$THEME"

gpu = "$GPU"
rocm_version = "$ROCM"
EOF
  echo "  Config created!"
  echo ""
  echo -ne "\r  Generating flake.lock\n  [#############--]"
  sleep 1
  cp ./configuration.nix /etc/nixos/
  cd /etc/nixos || { echo "  [ERROR] can't cd to /etc/nixos"; exit 1; }
  if ! sudo nix flake update --extra-experimental-features "nix-command flakes"; then
    echo "  [ERROR] updating flake.lock: installation stopped, check /etc/nixos/flake.nix & other files in /etc/nixos and re-run generating flake.lock yourself then rebuild NixOS and restart PC."
    exit 1
  fi
  cd ~/
  echo ""
  echo -ne "\r  Checking files     \n  [##############-]"
  sleep 1
  if [[ -f /etc/nixos/configuration.nix && -f /etc/nixos/flake.nix && -f /etc/nixos/flake.lock && -f /etc/nixos/user-config.toml && -f /etc/nixos/hardware-configuration.nix ]]; then
    echo "  Building the system:"
    if sudo nixos-rebuild switch; then
      echo "  System was built! restart PC)"
      exit 0
    else
      echo "  [ERROR] building stopped! Check it yourself."
      exit 1
    fi
  else
    echo "  [ERROR] installation stopped, check /etc/nixos files and restart it yourself."
    exit 1
  fi
}

# start
echo "Hello, this script for installation JES (Just Enough Shell)!"
echo ""
sleep 0.2
# set language
read -p "You use russian or english? Please write your language [eng|rus]:  " lang

lang=$(echo "$lang" | tr '[:upper:]' '[:lower:]')

case $lang in
  eng|en|e|english)
    echo "Using English localization"
    echo ""
    en_warning
    en_back
    en_install
    ;;
  rus|ru|r|russian|русский|ру)
    echo "Использование русской локализации"
    echo ""
    ru_warning
    ru_back
    ru_install
    ;;
  *)
    echo "ERROR: Unknown language, using English localization!!!"
    echo ""
    en_warning
    en_back
    en_install
    ;;
esac


