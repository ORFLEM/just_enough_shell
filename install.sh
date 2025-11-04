#!/usr/bin/env bash

# Installation for my configs

# variables
programs_flatpak="app.zen_browser.zen"
SYSTEM_CONF="$HOME/orflem_nixos_configs/configuration.nix"
BACKUP_DIR="$HOME/Your_old_configs"
SYS_CONF_FILES="$BACKUP_DIR/configuration.nix"
FLAKE="$HOME/orflem_nixos_configs/flake.nix"
LOCK="$HOME/orflem_nixos_configs/flake.lock"
RU_CONF="$HOME/orflem_nixos_configs/rus/config"
EN_CONF="$HOME/orflem_nixos_configs/eng/config"
CONFIG_DIR="$HOME/.config/"
USED_CONF="$EN_CONF"

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
  echo "Создание сохранений, требуется sudo права"

  if ! mkdir -p "$BACKUP_DIR"; then
        echo "ОШИБКА: не удалось создать директорию бэкапов"
        exit 1
  fi
  
  echo "  Создание сохранения конфигурации NixOS"
  sudo cp -r /etc/nixos "$BACKUP_DIR/nixos-$(date +%Y.%m.%d-%H:%M:%S)"

  echo "  Создание сохранения директории конфигураций пользователя"
  cp -r "$CONFIG_DIR" "$BACKUP_DIR/configs-$(date +%Y.%m.%d-%H:%M:%S)"

  echo "  Создание сохранения конфигурации bash"
  cp "$HOME/.bashrc" "$HOME/.bash_profile" "$BACKUP_DIR/bash-$(date +%Y.%m.%d-%H:%M:%S)"
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
  cp "$HOME/.bashrc" "$HOME/.bash_profile" "$BACKUP_DIR/bash-$(date +%Y.%m.%d-%H:%M:%S)"
}

# rewrite configs



# start
echo "Hello, this script for installation my dotfiles!"
echo ""
sleep 0.2
# set language
read -p "You use russian or english? Please write your language [eng|rus]:  " lang

lang=$(echo "$lang" | tr '[:upper:]' '[:lower:]')

case $lang in
  eng|en|e|english)
    echo "Using English localization"
    echo ""
    USED_CONF="$EN_CONF"
    LOCALE="en_US.UTF-8"
    en_warning
    en_back
    ;;
  rus|ru|r|russian|русский|ру)
    echo "Использование русской локализации"
    echo ""
    USED_CONF="$RU_CONF"
    LOCALE="ru_RU.UTF-8"
    ru_warning
    ru_back
    ;;
  *)
    echo "ERROR: Unknown language, using English localization!!!"
    echo ""
    USED_CONF="$EN_CONF"
    LOCALE="en_US.UTF-8"
    en_warning
    en_back
    ;;
esac


