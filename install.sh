#!/usr/bin/env bash

# ============================================
# Реальный установщик конфигураций JES
# ============================================

# ---------------- Вспомогательные функции ----------------

# Анимированный вывод текста (посимвольно)
animate_text() {
    local text="$1"
    local delay="${2:-0.02}"
    local newline="${3:-1}"
    local i
    for (( i=0; i<${#text}; i++ )); do
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
FULL_INSTALL=false
REBUILD=false

# ---------------- Предупреждения ----------------

ru_warning() {
    animate_text "ВНИМАНИЕ: дальше будут СОХРАНЕНЫ И ПЕРЕЗАПИСАНЫ ваши конфигурации!! Вы уверены?"
    animate_text "  Прошу укажите ваше решение [да|yes|нет|no]:  " 0.02 0
    read shure
    shure=$(echo "$shure" | tr '[:upper:]' '[:lower:]')
    case $shure in
        да|д|yes|y|"")
            echo
            animate_text "Принято, сейчас будут созданы сохранения и перезаписаны нынешние"
            sleep 1
            ;;
        нет|н|no|n)
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
        yes|ye|y|"")
            echo
            animate_text "Accepted, now creating backups and overwriting current configurations"
            sleep 1
            ;;
        no|n)
            echo
            animate_text "Accepted, stopping script. Have a nice day)"
            exit 0
            ;;
    esac
}

# ---------------- Вопрос о полной/частичной установке и сборке ----------------
ask_full_install_ru() {
    animate_text "ВНИМАНИЕ: полная установка предназначена только для систем с видеокартой AMD! Если у вас стоит иная, то сборка системы не пройдёт, чтобы вы могли изменить параметры конфигурации NixOS."
    animate_text "У вас видеокарта от AMD [yes|да|no|нет]:  " 0.02 0
    read amd
    amd=$(echo "$amd" | tr '[:upper:]' '[:lower:]')
    case $amd in
        yes|ye|y|д|да|"")
            echo
            animate_text "Система будет собрана по окончании установщика"
            REBUILD=true
            ;;
        no|n|нет|не|н)
            echo
            animate_text "автосборка отменена, установка только файлов и обновления состояния пакетного менеджера"
            REBUILD=false
            ;;
    esac
    echo
    animate_text "Установить преднастройку всей системы (нет = установить только JES) [yes|no|да|нет]: " 0.02 0
    read ans
    ans=$(echo "$ans" | tr '[:upper:]' '[:lower:]')
    case $ans in
        yes|ye|y|д|да|"")
            echo
            animate_text "Установка всех преднастроек:"
            FULL_INSTALL=true
            ;;
        no|n|нет|не|н)
            echo
            animate_text "Установка только JES:"
            FULL_INSTALL=false
            ;;
    esac

    # Если выбрана частичная установка — уточняем, для разработки или для обычного использования
    if [[ "$FULL_INSTALL" == false ]]; then
        echo
        animate_text "Вы собираетесь разрабатывать что-либо под JES? [yes|да|no|нет]: " 0.02 0
        read dev
        dev=$(echo "$dev" | tr '[:upper:]' '[:lower:]')
        case $dev in
            no|n|нет|не|н)
                echo
                animate_text "Установка для обычных юзеров сделана через flake. В документации проекта это прописано. Хорошего вам дня)"
                exit 0
                ;;
            yes|ye|y|д|да|"")
                echo
                animate_text "Продолжаем установку JES для разработки."
                ;;
        esac
    fi
}

ask_full_install_en() {
    animate_text "WARNING: full installation is intended only for systems with AMD GPU! If you have a different GPU, the system build will fail, so you can adjust NixOS configuration later."
    animate_text "Do you have an AMD GPU? [yes|no]:  " 0.02 0
    read amd
    amd=$(echo "$amd" | tr '[:upper:]' '[:lower:]')
    case $amd in
        yes|ye|y|"")
            echo
            animate_text "System will be rebuilt at the end of the installation"
            REBUILD=true
            ;;
        no|n)
            echo
            animate_text "Auto-rebuild disabled, only files will be installed and flake.lock updated"
            REBUILD=false
            ;;
    esac
    echo
    animate_text "Install full system preset (no = install only JES) [yes|no]: " 0.02 0
    read ans
    ans=$(echo "$ans" | tr '[:upper:]' '[:lower:]')
    case $ans in
        yes|ye|y|"")
            echo
            animate_text "Installing all presets:"
            FULL_INSTALL=true
            ;;
        no|n)
            echo
            animate_text "Installing only JES:"
            FULL_INSTALL=false
            ;;
    esac

    # If partial installation chosen, ask about development
    if [[ "$FULL_INSTALL" == false ]]; then
        echo
        animate_text "Are you going to develop something for JES? [yes|no]: " 0.02 0
        read dev
        dev=$(echo "$dev" | tr '[:upper:]' '[:lower:]')
        case $dev in
            no|n)
                echo
                animate_text "Installation for regular users is done via flake. It's described in the project documentation. Have a nice day)"
                exit 0
                ;;
            yes|ye|y|"")
                echo
                animate_text "Continuing JES installation for development."
                ;;
        esac
    fi
}

# ---------------- Создание бэкапов (с учётом FULL_INSTALL) ----------------

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
    animate_text "  Создание сохранения конфигурации NixOS"
    sudo cp -r /etc/nixos "$BACKUP_DIR/nixos-$(date +%Y.%m.%d-%H:%M:%S)"
    animate_text "  Создание сохранения конфигурации bash"
    cp "$HOME/.bashrc" "$BACKUP_DIR/bashrc-$(date +%Y.%m.%d-%H:%M:%S)"
    [ -f "$HOME/.bash_profile" ] && cp "$HOME/.bash_profile" "$BACKUP_DIR/bash_profile-$(date +%Y.%m.%d-%H:%M:%S)"
    if [[ "$FULL_INSTALL" == true ]]; then
        animate_text "  Создание сохранения пользовательских конфигов (.config)"
        cp -r "$CONFIG_DIR" "$BACKUP_DIR/configs-$(date +%Y.%m.%d-%H:%M:%S)"
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
    animate_text " Creating NixOS configuration backup"
    sudo cp -r /etc/nixos "$BACKUP_DIR/nixos-$(date +%Y.%m.%d-%H:%M:%S)"
    animate_text " Creating bash configuration backup"
    cp "$HOME/.bashrc" "$BACKUP_DIR/bashrc-$(date +%Y.%m.%d-%H:%M:%S)"
    [ -f "$HOME/.bash_profile" ] && cp "$HOME/.bash_profile" "$BACKUP_DIR/bash_profile-$(date +%Y.%m.%d-%H:%M:%S)"
    if [[ "$FULL_INSTALL" == true ]]; then
        animate_text " Creating user configs directory backup (.config)"
        cp -r "$CONFIG_DIR" "$BACKUP_DIR/configs-$(date +%Y.%m.%d-%H:%M:%S)"
    else
        animate_text " (skipping .config backup, because partial installation chosen)"
    fi
}

# ---------------- Основная установка (русская) ----------------

ru_install() {
    echo
    animate_text "Установка JES:"
    animate_text " проверка наличия файлов"
    echo -ne "\033[F"
    for item in ".local" ".config" ".bashrc" ".bash_profile" "flake.nix" "configuration.nix"; do
        echo -ne "\r  проверка наличия файлов.  "
        sleep 0.15
        echo -ne "\r  проверка наличия файлов.. "
        sleep 0.15
        echo -ne "\r  проверка наличия файлов..."
        sleep 0.15
        echo -ne "\r  проверка наличия файлов .."
        sleep 0.15
        echo -ne "\r  проверка наличия файлов  ."
        sleep 0.15
        echo -ne "\r  проверка наличия файлов   "
        sleep 0.15
        if [ ! -e "./$item" ]; then
            echo "  ОШИБКА: файл/директория ./$item не найдены"
            exit 1
        fi
    done

    if [[ "$FULL_INSTALL" == true ]]; then
        echo -en "\n\r  [#--------------]\r"
        echo -ne "\033[F"
        echo -ne "                       \r"
        animate_text "  установка файлов .config"
        cp -r ./.config/ ~/.config/
        sleep 1
    else
        echo -en "\n\r  [#--------------]\r"
        echo -ne "\033[F"
        echo -ne "                       \r"
        animate_text "  установка файлов .config (только JES-часть, если есть)"
        cp -r ./.config/ ~/.config/
        sleep 1
    fi

    echo -en "\n\r  [##-------------]\r"
    echo -ne "\033[F"
    echo -ne "                       \r"
    animate_text "  создание директорий в .cache"
    mkdir -p ./.cache/JES/walls
    mkdir -p ./.cache/JES/wall_prevs
    sleep 1
    echo -en "  [###------------]\r"
    mkdir -p ./.cache/JES/jes_music_art
    sleep 1

    if [[ "$FULL_INSTALL" == true ]]; then
        echo -en "\n\r  [####-----------]\r"
        echo -ne "\033[F"
        echo -ne "                       \r"
        animate_text "  установка файлов .bash"
        cp ./.bashrc ~/
        sleep 1
        echo -en "  [#####----------]\r"
        cp ./.bash_profile ~/
        sleep 1
        echo -en "\n\r  [######---------]\r"
        echo -ne "\033[F"
        echo -ne "                        \r"
        animate_text "  установка файлов NixOS"
        sudo cp ./installer/flake.nix /etc/nixos/
        sleep 1
        echo -en "  [#######--------]\r"
        USERNAME=$(grep 'users.users.' /etc/nixos/configuration.nix | awk -F '.' '{print $3}' | awk -F ' ' '{print $1}')
        sleep 1
        echo -en "  [########-------]\r"
        TIMEZONE=$(grep 'time.timeZone' /etc/nixos/configuration.nix | awk -F ' ' '{print $3}' | cut -d '"' -f 2)
        sleep 1
        echo -en "  [#########------]\r"
        PREFERED_WM=sway
        HOSTNAME=${HOSTNAME:-$(hostname)}
        sleep 1
        echo -en "  [##########-----]\r"
        THEME="zenburn"
        sleep 1
        echo -en "  [###########----]\r"
        USER_DESCRIPTION=$(awk -v usr="$USERNAME" '$0 ~ "users.users." usr {in_block=1} in_block && /description/ {print $0; exit} in_block && /};/ {exit}' /etc/nixos/configuration.nix | cut -d '"' -f 2)

        echo -e "\r  Проверьте данные: "
        animate_text "    username = $USERNAME"
        animate_text "    hostname = $HOSTNAME"
        animate_text "    timezone = $TIMEZONE"
        animate_text "    description = $USER_DESCRIPTION"
        animate_text "  [да|yes|нет|no]:  " 0.02 0
        read shure
        shure=$(echo "$shure" | tr '[:upper:]' '[:lower:]')
        case $shure in
            да|д|yes|ye|y|"")
                echo
                animate_text "  Введите предпочитаемый WM [$PREFERED_WM]: " 0.02 0
                read input_wm
                [ -n "$input_wm" ] && PREFERED_WM=$input_wm
                echo
                animate_text "  Принято, генерируем конфиг"
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
                echo
                animate_text "  Режим ручного ввода данных:"
                animate_text "  Введите username [$USERNAME]: " 0.02 0
                read input_user
                [ -n "$input_user" ] && USERNAME=$input_user

                animate_text "  Введите hostname [$HOSTNAME]: " 0.02 0
                read input_host
                [ -n "$input_host" ] && HOSTNAME=$input_host

                animate_text "  Введите timezone [$TIMEZONE]: " 0.02 0
                read input_zone
                [ -n "$input_zone" ] && TIMEZONE=$input_zone

                animate_text "  Введите description [$USER_DESCRIPTION]: " 0.02 0
                read input_desc
                [ -n "$input_desc" ] && USER_DESCRIPTION=$input_desc

                animate_text "  Введите предпочитаемый WM [$PREFERED_WM]: " 0.02 0
                read input_wm
                [ -n "$input_wm" ] && PREFERED_WM=$input_wm

                echo
                animate_text "  Данные успешно обновлены вручную!"
                animate_text "  Генерируем конфиг"
                repeat=0
                while [ $repeat -lt 4 ]; do
                    echo -ne "\033[F\r  Генерируем конфиг.  \n  [###########----]"
                    sleep 0.15
                    echo -ne "\033[F\r  Генерируем конфиг.. \n  [###########----]"
                    sleep 0.15
                    echo -ne "\033[F\r  Генерируем конфиг...\n  [###########----]"
                    sleep 0.15
                    echo -ne "\033[F\r  Генерируем конфиг ..\n  [############---]"
                    sleep 0.15
                    echo -ne "\033[F\r  Генерируем конфиг  .\n  [############---]"
                    sleep 0.15
                    echo -ne "\033[F\r  Генерируем конфиг   \n  [############---]"
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
EOF
        echo -ne "\r"
        animate_text "  Конфиг успешно создан!"
        echo
        echo -ne "\r  генерация flake.lock\n  [#############--]"
        sleep 1
        sudo cp ./installer/configuration.nix /etc/nixos/
        cd /etc/nixos || { animate_text "  [ERROR] Не удалось перейти в /etc/nixos"; exit 1; }
        if ! sudo nix flake update --extra-experimental-features "nix-command flakes"; then
            animate_text "  [ERROR] Ошибка обновления flake.lock: установка преостановлена, проверьте /etc/nixos/flake.nix + другие файлы в /etc/nixos и запустите сборку flake и системы вручную, а после перезапустите ПК."
            exit 1
        fi
        cd ~/
        echo -ne "\r"
        animate_text "  (имитация) flake.lock обновлён"
        echo
        echo -ne "\r  проверка файлов  \n  [##############-]"
        sleep 1
        echo -ne "\r"
        if [[ $REBUILD == true ]]; then
            if [[ -f /etc/nixos/configuration.nix && -f /etc/nixos/flake.nix && -f /etc/nixos/flake.lock && -f /etc/nixos/user-config.toml && -f /etc/nixos/hardware-configuration.nix ]]; then
                animate_text "  Сборка системы:   "
                if sudo nixos-rebuild switch; then
                    animate_text "  сборка закончена! перезапустите ПК)"
                    exit 0
                else
                    animate_text "  [ERROR] Ошибка сборки! Проверьте сборку вручную."
                    exit 1
                fi
            else
                animate_text "  [ERROR] Ошибка генерации: установка преостановлена, проверьте /etc/nixos и запустите сборку системы вручную, а после перезапустите ПК."
                exit 1
            fi
        else
            animate_text "  Автосборка отключена. Файлы обновлены, вы можете собрать систему вручную командой 'sudo nixos-rebuild switch'."
        fi
    else
        # Частичная установка (только JES)
        sudo cp ./installer/JES.nix /etc/nixos/
        animate_text "  Основные файлы были установлены, просьба установить в imports модуль JES (JES.nix) и включить через services.jes.enable"
    fi
}

# ---------------- Основная установка (английская) ----------------

en_install() {
    echo
    animate_text "Installing JES:"
    animate_text " checking files"
    echo -ne "\033[F"
    for item in ".local" ".config" ".bashrc" ".bash_profile" "flake.nix" "configuration.nix"; do
        echo -ne "\r  checking files.  "
        sleep 0.15
        echo -ne "\r  checking files.. "
        sleep 0.15
        echo -ne "\r  checking files..."
        sleep 0.15
        echo -ne "\r  checking files .."
        sleep 0.15
        echo -ne "\r  checking files  ."
        sleep 0.15
        echo -ne "\r  checking files   "
        sleep 0.15
        if [ ! -e "./$item" ]; then
            echo "  ERROR: file/directory ./$item not found"
            exit 1
        fi
    done

    echo -en "\n\r  [#--------------]\r"
    echo -ne "\033[F"
    echo -ne "                       \r"
    if [[ "$FULL_INSTALL" == true ]]; then
        animate_text "  installing .config"
        cp -r ./.config/ ~/.config/
        sleep 1
    else
        animate_text "  installing .config (JES part only)"
        cp -r ./.config/ ~/.config/
        sleep 1
    fi

    echo -en "\n\r  [##-------------]\r"
    echo -ne "\033[F"
    echo -ne "                       \r"
    animate_text "  creating cache directories"
    mkdir -p ./.cache/JES/walls
    mkdir -p ./.cache/JES/wall_prevs
    mkdir -p ./.cache/JES/jes_music_art
    sleep 1

    if [[ "$FULL_INSTALL" == true ]]; then
        echo -en "\n\r  [####-----------]\r"
        echo -ne "\033[F"
        echo -ne "                       \r"
        animate_text "  installing .bash"
        cp ./.bashrc ~/
        sleep 1
        echo -en "  [#####----------]\r"
        cp ./.bash_profile ~/
        sleep 1
        echo -en "\n\r  [######---------]\r"
        echo -ne "\033[F"
        echo -ne "                        \r"
        animate_text "  installing NixOS configuration"
        sudo cp ./flake.nix /etc/nixos/
        sleep 1
        echo -en "  [#######--------]\r"
        USERNAME=$(grep 'users.users.' /etc/nixos/configuration.nix | awk -F '.' '{print $3}' | awk -F ' ' '{print $1}')
        sleep 1
        echo -en "  [########-------]\r"
        TIMEZONE=$(grep 'time.timeZone' /etc/nixos/configuration.nix | awk -F ' ' '{print $3}' | cut -d '"' -f 2)
        sleep 1
        echo -en "  [#########------]\r"
        PREFERED_WM=sway
        HOSTNAME=${HOSTNAME:-$(hostname)}
        sleep 1
        echo -en "  [##########-----]\r"
        THEME="zenburn"
        sleep 1
        echo -en "  [###########----]\r"
        USER_DESCRIPTION=$(awk -v usr="$USERNAME" '$0 ~ "users.users." usr {in_block=1} in_block && /description/ {print $0; exit} in_block && /};/ {exit}' /etc/nixos/configuration.nix | cut -d '"' -f 2)

        echo -e "\r  Check user's info: "
        animate_text "    username = $USERNAME"
        animate_text "    hostname = $HOSTNAME"
        animate_text "    timezone = $TIMEZONE"
        animate_text "    description = $USER_DESCRIPTION"
        animate_text "  [yes|no]:  " 0.02 0
        read shure
        shure=$(echo "$shure" | tr '[:upper:]' '[:lower:]')
        case $shure in
            yes|ye|y|"")
                echo
                animate_text "  Write preferred WM [$PREFERED_WM]: " 0.02 0
                read input_wm
                [ -n "$input_wm" ] && PREFERED_WM=$input_wm
                echo
                animate_text "  Accepted, generating config"
                repeat=0
                while [ $repeat -lt 4 ]; do
                    echo -ne "\033[F\r  Accepted, generating config.  \n  [###########----]"
                    sleep 0.15
                    echo -ne "\033[F\r  Accepted, generating config.. \n  [###########----]"
                    sleep 0.15
                    echo -ne "\033[F\r  Accepted, generating config...\n  [###########----]"
                    sleep 0.15
                    echo -ne "\033[F\r  Accepted, generating config ..\n  [############---]"
                    sleep 0.15
                    echo -ne "\033[F\r  Accepted, generating config  .\n  [############---]"
                    sleep 0.15
                    echo -ne "\033[F\r  Accepted, generating config   \n  [############---]"
                    sleep 0.15
                    repeat=$((repeat + 1))
                done
                ;;

            no|n)
                echo
                animate_text "  Manual input mode:"
                animate_text "  Write username [$USERNAME]: " 0.02 0
                read input_user
                [ -n "$input_user" ] && USERNAME=$input_user

                animate_text "  Write hostname [$HOSTNAME]: " 0.02 0
                read input_host
                [ -n "$input_host" ] && HOSTNAME=$input_host

                animate_text "  Write timezone [$TIMEZONE]: " 0.02 0
                read input_zone
                [ -n "$input_zone" ] && TIMEZONE=$input_zone

                animate_text "  Write description [$USER_DESCRIPTION]: " 0.02 0
                read input_desc
                [ -n "$input_desc" ] && USER_DESCRIPTION=$input_desc

                animate_text "  Write preferred WM [$PREFERED_WM]: " 0.02 0
                read input_wm
                [ -n "$input_wm" ] && PREFERED_WM=$input_wm

                echo
                animate_text "  Info updated manually!"
                animate_text "  Generating config"
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
EOF
        echo -ne "\r"
        animate_text "  Config successfully created!"
        echo
        echo -ne "\r  generating flake.lock\n  [#############--]"
        sleep 1
        sudo cp ./configuration.nix /etc/nixos/
        cd /etc/nixos || { animate_text "  [ERROR] can't cd to /etc/nixos"; exit 1; }
        if ! sudo nix flake update --extra-experimental-features "nix-command flakes"; then
            animate_text "  [ERROR] updating flake.lock: installation stopped, check /etc/nixos/flake.nix & other files in /etc/nixos and re-run generating flake.lock yourself then rebuild NixOS and restart PC."
            exit 1
        fi
        cd ~/
        echo -ne "\r"
        animate_text "  flake.lock updated"
        echo
        echo -ne "\r  checking files  \n  [##############-]"
        sleep 1
        echo -ne "\r"
        if [[ $REBUILD == true ]]; then
            if [[ -f /etc/nixos/configuration.nix && -f /etc/nixos/flake.nix && -f /etc/nixos/flake.lock && -f /etc/nixos/user-config.toml && -f /etc/nixos/hardware-configuration.nix ]]; then
                animate_text "  Building the system:   "
                if sudo nixos-rebuild switch; then
                    animate_text "  Build finished! restart PC)"
                    exit 0
                else
                    animate_text "  [ERROR] building stopped! Check it yourself."
                    exit 1
                fi
            else
                animate_text "  [ERROR] installation stopped, check /etc/nixos files and restart it yourself."
                exit 1
            fi
        else
            animate_text "  Auto-rebuild disabled. Files updated, you can rebuild manually with 'sudo nixos-rebuild switch'."
        fi
    else
        # only JES
        sudo cp ./JES.nix /etc/nixos/
        animate_text "  Main files installed, please add JES module (JES.nix) to imports and enable via services.jes.enable"
    fi
}

# ---------------- Основной запуск ----------------

animate_text "Hello, this script for installation JES (Just Enough Shell)!"
echo
sleep 0.2

animate_text "You use russian or english? Please write your language [eng|rus]:  " 0.02 0
read lang
lang=$(echo "$lang" | tr '[:upper:]' '[:lower:]')

case $lang in
    eng|en|e|english)
        animate_text "Using English localization"
        echo
        en_warning
        ask_full_install_en
        en_back
        en_install
        ;;
    rus|ru|r|russian|русский|ру)
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
