if status is-interactive

    #games
    alias tetris='bastet'
    alias snake='nsnake'
    alias moonbuggy='moon-buggy'

    #change ls on lsd
    alias ls='lsd --group-dirs first --date relative --size short --icon always -a'

    #info
    alias apa-f='apa info'

    #install
    alias i='epmi'
    alias apa-i='sudo apa install'
    alias f-i='flatpak install'

    #unistall
    alias i-e='epm -e'
    alias apa-r='sudo apa remove'
    alias apa-ar='sudo apa autoremove'

    #update
    alias up='epm update'
    alias fup='epm full-upgrade'

    #clear
    alias c='clear'

    #root
    alias op='su -'

    #micro
    alias mc='micro'
    alias mc-hypr='micro ~/.config/hypr/hyprland.conf'
    alias mc-niri='micro ~/.config/niri/config.kdl'
    alias mc-kitty='micro ~/.config/kitty/kitty.conf'
    alias mc-fish='micro ~/.config/fish/config.fish'
    alias mc-nix='micro /etc/nixos/configuration.nix'

    #eww
    alias mc-hbar='micro ~/.config/eww/bar/hbar.yuck'
    alias mc-nbar='micro ~/.config/eww/bar/nbar.yuck'
    alias mc-eww='micro ~/.config/eww/eww.yuck'
    alias mc-ewwstl='micro ~/.config/eww/eww.scss'
    alias mc-barstl='micro ~/.config/eww/bar/bar.scss'
    alias mc-btime='micro ~/.config/eww/Btime/btime.yuck'
    alias mc-roundm='micro "~/.config/eww/round monitor/roundm.yuck"'
    alias mc-roundmstl='micro "~/.config/eww/round monitor/roundm.scss"'
    alias mc-variables='micro ~/.config/eww/bar/variables&polling.yuck'
    alias mc-pwr='micro ~/.config/eww/power_pc/power.yuck'
    alias mc-pwrstl='micro ~/.config/eww/power_pc/power.scss'

    alias mc-clrs='micro ~/Документы/документы/colors.txt'
    alias mc-sddm='micro /usr/share/sddm/themes/ximper/theme.conf'

    #helix
    alias mc='micro'
    alias hx-hypr='hx ~/.config/hypr/hyprland.conf'
    alias hx-niri='hx ~/.config/niri/config.kdl'
    alias hx-kitty='hx ~/.config/kitty/kitty.conf'
    alias hx-fish='hx ~/.config/fish/config.fish'
    alias hx-nix='hx /etc/nixos/configuration.nix'

    #eww
    alias hx-hbar='hx ~/.config/eww/bar/hbar.yuck'
    alias hx-nbar='hx ~/.config/eww/bar/nbar.yuck'
    alias hx-eww='hx ~/.config/eww/eww.yuck'
    alias hx-ewwstl='hx ~/.config/eww/eww.scss'
    alias hx-barstl='hx ~/.config/eww/bar/bar.scss'
    alias hx-btime='hx ~/.config/eww/Btime/btime.yuck'
    alias hx-roundm='hx "~/.config/eww/round monitor/roundm.yuck"'
    alias hx-roundmstl='hx "~/.config/eww/round monitor/roundm.scss"'
    alias hx-variables='hx ~/.config/eww/bar/variables&polling.yuck'
    alias hx-pwr='hx ~/.config/eww/power_pc/power.yuck'
    alias hx-pwrstl='hx ~/.config/eww/power_pc/power.scss'

    alias hx-clrs='micro ~/Документы/документы/colors.txt'
    alias hx-sddm='micro /usr/share/sddm/themes/ximper/theme.conf'

    alias check="ps aux | grep -E 'hyprland|firefox|eww|pipewire|mpvpaper' | grep -v grep | awk '{print \$11}' | sort | uniq -c | sort -nr"

    alias weather="sh -c '~/.config/fish/weather.sh' | pv -qL 1500"

    alias confeww='~/.config/eww/'

    #ru
    #игры
    alias тетрис='bastet'
    alias змейка='nsnake'
    alias мунбагги='moon-buggy'

    #информация
    alias апа-инф='apa info'

    #скачать
    alias и='epmi'
    alias апа-и='sudo apa install'
    alias флэт-и='flatpak install'

    #удалить
    alias епм-уд='epm -e'
    alias апа-уд='sudo apa remove'

    #обновить
    alias обнова='epm update'
    alias фулл='epm full-upgrade'

    #очистить
    alias с='clear'

    #админка
    alias оп='su -'

    #micro
    alias мс='micro'
    alias мс-хупр='micro ~/.config/hypr/hyprland.conf'
    alias мс-рыба='micro ~/.config/fish/config.fish'

end
