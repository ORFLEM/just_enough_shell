#!/usr/bin/env bash

# ============================================
# Установщик конфигураций JES для Arch Linux
# ============================================

# ---------------- Вспомогательные функции ----------------

animate_text() {
  local text="$1"
  local delay="${2:-0.02}"
  local newline="${3:-1}"
  local i
  for ((i = 0; i < ${#text}; i++)); do
    local char="${text:$i:1}"
    echo -n "$char"
    sleep "$delay"
  done
  if [ "$newline" -eq 1 ]; then
    echo ""
  fi
}

# ---------------- Переменные ----------------
BACKUP_DIR="$HOME/Your_old_configs"
CONFIG_DIR="$HOME/.config"
OFFICIAL_LIST="./installer/arch_official.txt"
AUR_LIST="./installer/arch_aur.txt"
FULL_INSTALL=false

# ---------------- Предупреждения ----------------

ru_warning() {
  animate_text "ВНИМАНИЕ: дальше будут СОХРАНЕНЫ И ПЕРЕЗАПИСАНЫ ваши конфигурации!! Вы уверены?"
  animate_text "  Прошу укажите ваше решение [да|yes|нет|no]:  " 0.02 0
  read shure
  shure=$(echo "$shure" | tr '[:upper:]' '[:lower:]')
  case $shure in
  да | д | yes | y | "")
    echo
    animate_text "Принято, сейчас будут созданы сохранения и перезаписаны нынешние"
    sleep 1
    ;;
  нет | н | no | n)
    echo
    animate_text "Принято, остановка скрипта, доброго дня вам)"
    exit 0
    ;;
  esac
}

en_warning() {
  animate_text "WARNING: Your configurations will be SAVED and OVERWRITTEN!! Are you sure?"
  animate_text " Please specify your decision [yes|no]: " 0.02 0
  read shure
  shure=$(echo "$shure" | tr '[:upper:]' '[:lower:]')
  case $shure in
  yes | ye | y | "")
    echo
    animate_text "Accepted, now creating backups and overwriting current configurations"
    sleep 1
    ;;
  no | n)
    echo
    animate_text "Accepted, stopping script. Have a nice day)"
    exit 0
    ;;
  esac
}

# ---------------- Вопрос о полной/частичной установке ----------------

ask_full_install_ru() {
  animate_text "Установить полный набор преднастроек системы (нет = установить только JES и его зависимости) [yes|no|да|нет]: " 0.02 0
  read ans
  ans=$(echo "$ans" | tr '[:upper:]' '[:lower:]')
  case $ans in
  yes | ye | y | д | да | "")
    echo
    animate_text "Установка всех преднастроек:"
    FULL_INSTALL=true
    ;;
  no | n | нет | не | н | *)
    echo
    animate_text "Установка только JES:"
    FULL_INSTALL=false
    ;;
  esac
}

ask_full_install_en() {
  animate_text "Install full system preset (no = install only JES and dependencies) [yes|no]: " 0.02 0
  read ans
  ans=$(echo "$ans" | tr '[:upper:]' '[:lower:]')
  case $ans in
  yes | ye | y | "")
    echo
    animate_text "Installing all presets:"
    FULL_INSTALL=true
    ;;
  no | n | *)
    echo
    animate_text "Installing only JES:"
    FULL_INSTALL=false
    ;;
  esac
}

# ---------------- Создание бэкапов ----------------

ru_back() {
  echo
  animate_text "Создание сохранений:"
  if ! sudo -v; then
    animate_text "Требуются права sudo"
    exit 1
  fi
  if ! mkdir -p "$BACKUP_DIR"; then
    animate_text "ОШИБКА: не удалось создать директорию бэкапов"
    exit 1
  fi
  animate_text "  Создание сохранения конфигурации bash"
  [ -f "$HOME/.bashrc" ] && cp "$HOME/.bashrc" "$BACKUP_DIR/bashrc-$(date +%Y.%m.%d-%H:%M:%S)"
  [ -f "$HOME/.bash_profile" ] && cp "$HOME/.bash_profile" "$BACKUP_DIR/bash_profile-$(date +%Y.%m.%d-%H:%M:%S)"
  [ -d "$CONFIG_DIR/JES" ] && cp -r "$CONFIG_DIR/JES" "$BACKUP_DIR/JES-$(date +%Y.%m.%d-%H:%M:%S)"
  if [[ "$FULL_INSTALL" == true ]]; then
    animate_text "  Создание сохранения пользовательских конфигов (.config)"
    [ -d "$CONFIG_DIR" ] && cp -r "$CONFIG_DIR" "$BACKUP_DIR/configs-$(date +%Y.%m.%d-%H:%M:%S)"
  else
    animate_text "  (пропуск бэкапа .config, т.к. выбрана частичная установка)"
  fi
}

en_back() {
  echo
  animate_text "Creating backups:"
  if ! sudo -v; then
    animate_text "sudo privileges required"
    exit 1
  fi
  if ! mkdir -p "$BACKUP_DIR"; then
    animate_text "ERROR: can't create backup directory"
    exit 1
  fi
  animate_text " Creating bash configuration backup"
  [ -f "$HOME/.bashrc" ] && cp "$HOME/.bashrc" "$BACKUP_DIR/bashrc-$(date +%Y.%m.%d-%H:%M:%S)"
  [ -f "$HOME/.bash_profile" ] && cp "$HOME/.bash_profile" "$BACKUP_DIR/bash_profile-$(date +%Y.%m.%d-%H:%M:%S)"
  [ -d "$CONFIG_DIR/JES" ] && cp -r "$CONFIG_DIR/JES" "$BACKUP_DIR/JES-$(date +%Y.%m.%d-%H:%M:%S)"
  if [[ "$FULL_INSTALL" == true ]]; then
    animate_text " Creating user configs directory backup (.config)"
    [ -d "$CONFIG_DIR" ] && cp -r "$CONFIG_DIR" "$BACKUP_DIR/configs-$(date +%Y.%m.%d-%H:%M:%S)"
  else
    animate_text " (skipping .config backup, because partial installation chosen)"
  fi
}

# ---------------- Вспомогательная функция установки пакетов ----------------

install_packages() {
  local lang_code="$1"

  # Официальные пакеты
  if [ -f "$OFFICIAL_LIST" ]; then
    local official_pkgs=($(sed -e 's/#.*//' "$OFFICIAL_LIST" | tr '\n' ' '))
    if [ ${#official_pkgs[@]} -gt 0 ]; then
      if [ "$lang_code" == "ru" ]; then
        animate_text "  установка официальных пакетов Arch..."
      else
        animate_text "  installing official Arch packages..."
      fi
      sudo pacman -S --needed --noconfirm "${official_pkgs[@]}"
    fi
  fi

  # AUR пакеты
  if [ -f "$AUR_LIST" ]; then
    local aur_pkgs=($(sed -e 's/#.*//' "$AUR_LIST" | tr '\n' ' '))
    if [ ${#aur_pkgs[@]} -gt 0 ]; then
      if [ "$lang_code" == "ru" ]; then
        animate_text "  установка пакетов из AUR..."
      else
        animate_text "  installing AUR packages..."
      fi

      if command -v yay &>/dev/null; then
        yay -S --needed --noconfirm "${aur_pkgs[@]}"
      elif command -v paru &>/dev/null; then
        paru -S --needed --noconfirm "${aur_pkgs[@]}"
      else
        if [ "$lang_code" == "ru" ]; then
          animate_text "  [ПРЕДУПРЕЖДЕНИЕ] yay/paru не найдены! Пакеты из AUR пропущены. Установите их вручную из $AUR_LIST"
        else
          animate_text "  [WARNING] yay/paru not found! AUR packages skipped. Install them manually from $AUR_LIST"
        fi
      fi
    fi
  fi
}

# ---------------- Основная установка (русская) ----------------

ru_install() {
  echo
  animate_text "Установка JES:"
  animate_text " проверка наличия файлов..."

  for item in ".local" ".config" "$OFFICIAL_LIST" "$AUR_LIST"; do
    if [ ! -e "$item" ]; then
      echo "  ОШИБКА: файл/директория $item не найдены"
      exit 1
    fi
  done

  echo
  animate_text "  [#--------------] установка пакетов Arch Linux"
  install_packages "ru"

  echo
  if [[ "$FULL_INSTALL" == true ]]; then
    animate_text "  [###------------] установка всех файлов .config"
    mkdir -p ~/.config
    cp -r ./.config/* ~/.config/ 2>/dev/null || true
  else
    animate_text "  [###------------] установка файлов .config (только JES)"
    mkdir -p ~/.config/JES
    [ -d "./.config/JES" ] && cp -r ./.config/JES/* ~/.config/JES/ 2>/dev/null || true
  fi

  echo
  animate_text "  [######---------] установка локальных скриптов и компонентов JES (.local)"
  mkdir -p ~/.local/bin ~/.local/state ~/.local/share

  [ -d "./.local" ] && cp -r ./.local/* ~/.local/ 2>/dev/null || true
  [ -d "~/.local/bin" ] && chmod +x ~/.local/bin/* 2>/dev/null || true

  echo
  animate_text "  [#########------] создание директорий в .cache"
  mkdir -p ~/.cache/JES/walls ~/.cache/JES/wall_prevs ~/.cache/JES/jes_music_art

  if [ ! -f "$HOME/.local/state/JES_colors.json" ]; then
    animate_text "  создание стандартного файла цветов JES_colors.json"
    cat <<'EOF' >"$HOME/.local/state/JES_colors.json"
{
  "background1": "#808080",
  "background2": "#6f6f6f",
  "background3": "#606060",
  "backgroundAlt1": "#383838",
  "backgroundAlt2": "#404040",
  "font": "#dcdccc",
  "fontDark": "#383838",
  "accent": "#ffffff",
  "accent2": "#808080"
}
EOF
  fi

  echo
  animate_text "  [###########----] настройка пользователя и группы i2c"
  sudo groupadd -f i2c
  sudo usermod -aG i2c,networkmanager "$USER"

  echo
  animate_text "  [#############--] настройка переменной PATH в .bashrc"
  if [ -f "$HOME/.bashrc" ]; then
    if ! grep -q 'export PATH="$HOME/.local/bin:$PATH"' "$HOME/.bashrc"; then
      echo 'export PATH="$HOME/.local/bin:$PATH"' >>"$HOME/.bashrc"
    fi
  fi

  echo
  animate_text "  [##############-] Установка JES для Arch Linux успешно завершена!"
  echo
  animate_text "Перезагрузить систему сейчас? [да|yes|нет|no]: " 0.02 0
  read reboot_choice
  reboot_choice=$(echo "$reboot_choice" | tr '[:upper:]' '[:lower:]')
  case $reboot_choice in
  да | д | yes | y)
    animate_text "Перезагрузка..."
    sudo reboot
    ;;
  *)
    animate_text "Перезагрузка отменена. Не забудьте перезайти в сессию или перезагрузить ПК вручную."
    ;;
  esac
}

# ---------------- Основная установка (английская) ----------------

en_install() {
  echo
  animate_text "Installing JES:"
  animate_text " checking files..."

  for item in ".local" ".config" "$OFFICIAL_LIST" "$AUR_LIST"; do
    if [ ! -e "$item" ]; then
      echo "  ERROR: file/directory $item not found"
      exit 1
    fi
  done

  echo
  animate_text "  [#--------------] installing Arch Linux packages"
  install_packages "en"

  echo
  if [[ "$FULL_INSTALL" == true ]]; then
    animate_text "  [###------------] installing all .config files"
    mkdir -p ~/.config
    cp -r ./.config/* ~/.config/ 2>/dev/null || true
  else
    animate_text "  [###------------] installing .config files (JES part only)"
    mkdir -p ~/.config/JES
    [ -d "./.config/JES" ] && cp -r ./.config/JES/* ~/.config/JES/ 2>/dev/null || true
  fi

  echo
  animate_text "  [######---------] installing JES local scripts and files (.local)"
  mkdir -p ~/.local/bin ~/.local/state ~/.local/share

  [ -d "./.local" ] && cp -r ./.local/* ~/.local/ 2>/dev/null || true
  [ -d "~/.local/bin" ] && chmod +x ~/.local/bin/* 2>/dev/null || true

  echo
  animate_text "  [#########------] creating cache directories"
  mkdir -p ~/.cache/JES/walls ~/.cache/JES/wall_prevs ~/.cache/JES/jes_music_art

  if [ ! -f "$HOME/.local/state/JES_colors.json" ]; then
    animate_text "  creating default JES_colors.json"
    cat <<'EOF' >"$HOME/.local/state/JES_colors.json"
{
  "background1": "#808080",
  "background2": "#6f6f6f",
  "background3": "#606060",
  "backgroundAlt1": "#383838",
  "backgroundAlt2": "#404040",
  "font": "#dcdccc",
  "fontDark": "#383838",
  "accent": "#ffffff",
  "accent2": "#808080"
}
EOF
  fi

  echo
  animate_text "  [###########----] setting up user groups (i2c)"
  sudo groupadd -f i2c
  sudo usermod -aG i2c,networkmanager "$USER"

  echo
  animate_text "  [#############--] configuring PATH variable in .bashrc"
  if [ -f "$HOME/.bashrc" ]; then
    if ! grep -q 'export PATH="$HOME/.local/bin:$PATH"' "$HOME/.bashrc"; then
      echo 'export PATH="$HOME/.local/bin:$PATH"' >>"$HOME/.bashrc"
    fi
    if ! grep -q 'export QML_IMPORT_PATH="$HOME/.local/JES/quickshell:/usr/lib/qt6/qml:$QML_IMPORT_PATH"' "$HOME/.bashrc"; then
      echo 'export QML_IMPORT_PATH="$HOME/.local/JES/quickshell:/usr/lib/qt6/qml:$QML_IMPORT_PATH"' >>"$HOME/.bashrc"
    fi
    if ! grep -q 'export QML2_IMPORT_PATH="/usr/lib/qt6/qml:$HOME/.local/JES/quickshell:$QML2_IMPORT_PATH"' "$HOME/.bashrc"; then
      echo 'export QML2_IMPORT_PATH="/usr/lib/qt6/qml:$HOME/.local/JES/quickshell:$QML2_IMPORT_PATH"' >>"$HOME/.bashrc"
    fi
  fi

  echo
  animate_text "  [##############-] JES installation for Arch Linux completed successfully!"
  echo
  animate_text "Reboot system now? [yes|no]: " 0.02 0
  read reboot_choice
  reboot_choice=$(echo "$reboot_choice" | tr '[:upper:]' '[:lower:]')
  case $reboot_choice in
  yes | ye | y)
    animate_text "Rebooting..."
    sudo reboot
    ;;
  *)
    animate_text "Reboot canceled. Please re-log or reboot manually later."
    ;;
  esac
}

# ---------------- Основной запуск ----------------

animate_text "Hello, this script for installation JES (Just Enough Shell) on Arch Linux!"
echo
sleep 0.2

animate_text "You use russian or english? Please write your language [eng|rus]:  " 0.02 0
read lang
lang=$(echo "$lang" | tr '[:upper:]' '[:lower:]')

case $lang in
eng | en | e | english)
  animate_text "Using English localization"
  echo
  en_warning
  ask_full_install_en
  en_back
  en_install
  ;;
rus | ru | r | russian | русский | ру)
  animate_text "Использование русской локализации"
  echo
  ru_warning
  ask_full_install_ru
  ru_back
  ru_install
  ;;
*)
  animate_text "ERROR: Unknown language, using English localization!!!"
  echo
  en_warning
  ask_full_install_en
  en_back
  en_install
  ;;
esac
