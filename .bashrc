function fancy_prompt {
# Цвета
local TIME_COLOR="\[\033[01;36m\]"    # Голубой (время)
local USER_COLOR="\[\033[01;32m\]"    # Зелёный (ник)
local DIR_COLOR="\[\033[01;34m\]"     # Синий (путь)
local GIT_COLOR="\[\033[01;35m\]"     # Пурпурный (гит)
local ERROR_COLOR="\[\033[01;31m\]"   # Красный (ошибки)
local BRACKET_COLOR="\[\033[01;32m\]" # Зелёный (скобки и $)
local RESET="\[\033[00m\]"            # Сброс цвета

# Функция для промпта

    # Время (ЧЧ:ММ)
    local current_time="\D{%H:%M}"

    # Пользователь
    local username="\u"

    # Директория (сокращённая)
    local dir="$PWD"
    
    # заменяем home на ~
    dir="${dir/#$HOME/\~}"
    
    # сокращения
    dir="${dir/#\~\/projects/\~\/proj}"
    dir="${dir/#\~\/documents/\~\/doc}"
    dir="${dir/#\~\/downloads/\~\/dl}"
    dir="${dir/#\~\/music/\~\/mus}"
    dir="${dir/#\~\/videos/\~\/vid}"
    dir="${dir/#\~\/pictures/\~\/pic}"
    dir="${dir/#\~\/.config/\~\/confs}"
    
    # Ветка гита
    local git_branch=""
    if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        local branch=$(git branch --show-current 2>/dev/null)
        if ! git diff --quiet 2>/dev/null; then
            git_branch=" ${ERROR_COLOR}${branch}${RESET}"  # Красный, если есть изменения
        else
            git_branch=" ${GIT_COLOR}${branch}${RESET}"     # Пурпурный, если всё чисто
        fi
    fi

    # Код возврата (если команда упала)
    local exit_status="$?"
    local status_prompt=""
    if [ "$exit_status" -ne 0 ]; then
        status_prompt=" ${ERROR_COLOR}[${exit_status}]${RESET}"
    fi

    # Формируем промпт в формате: [время - ник: путь (ветка)]
    PS1="\# ${BRACKET_COLOR}[${TIME_COLOR}${current_time}${RESET} - ${USER_COLOR}${username}${RESET}:${DIR_COLOR}${dir}${RESET}${git_branch}${status_prompt}${BRACKET_COLOR}]\$${RESET}  "
}

# Обновляем промпт перед каждой командой
PROMPT_COMMAND="fancy_prompt"

    [[ -z "$TMUX" && -z "$SSH_TTY" && $- == *i* ]] && cd ~
    # exports
    export EDITOR=hx
    export PATH=$HOME/.local/bin:$PATH

    # wallpaper engine
    # alias linwp='linux-wallpaperengine -r DP-3 --bg'

    # Показать картинки
    alias shw-img='chafa --format=sixel --scale max'

    # games
    alias tetris='bastet'
    alias snake='nsnake'
    alias moonbuggy='moon-buggy'

    # for unixPORN
    alias tty-clock='tty-clock -s -c -C 5'
    alias pipes.sh='pipes.sh -p 5 -f 60 -r 0'

    # change ls on lsd
    alias ls='lsd --group-dirs first --date relative --size short --icon auto -a'

    # clear
    alias c='clear'

    # root
    alias op='su -'

    # NixOS
	  # Быстрая пересборка
    alias nrs='sudo nixos-rebuild switch'
	  
	  # Тестовая сборка (без применения)
	  alias nrb='sudo nixos-rebuild build'
	  
	  # Откат на предыдущую генерацию
    alias nrr='sudo nixos-rebuild switch --rollback'
	  
	  # Просмотр различий между поколениями
    alias ndiff='sudo nix store diff-closures /run/current-system /var/run/current-system'
	  
    	# Очистка старых поколений
	  alias ngc='sudo nix-collect-garbage -d'

    # micro
    alias mic='micro'
    alias mic-nix='micro /etc/nixos/configuration.nix'

    # helix
    alias hx-hypr='hx ~/.config/hypr/hyprland.conf'
    alias hx-sway='hx ~/.config/sway/config'
   alias hx-niri='hx ~/.config/niri/config.kdl'
    alias hx-nix='sudo hx /etc/nixos/configuration.nix'

    # быстрый доступ
    alias cdqs='cd ~/.config/quickshell'
    alias cdconf='cd ~/.config/'
    alias cdnix='cd /etc/nixos/'

    # python
    alias py='python'

# eval "$(zoxide init bash)"
