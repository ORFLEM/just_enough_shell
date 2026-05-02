![last_commit](https://img.shields.io/github/last-commit/ORFLEM/just_enough_shell?&style=for-the-badge&color=bbbbbb&label=Последний%20коммит&logo=git&logoColor=D9E0EE&labelColor=1E202B)
![repo_size](https://img.shields.io/github/repo-size/ORFLEM/just_enough_shell?color=cccccc&label=Размер%20проекта&logo=protondrive&style=for-the-badge&logoColor=D9E0EE&labelColor=1E202B)

<div align="center">
	<img src="./images/preview.webp" width="900px">
	<h1>Just Enough Shell</h1>
	<p>Создан для повседневности, не для картинок.</p>
</div>

***

<table align="right">
	<tr>
		<td colspan="2" align="center">Системные параметры</td>
	</tr>
	<tr>
		<th>Компонент</th>
		<th>Значение</th>
	</tr>
	<tr>
		<td>OS</td>
		<td>NixOS 25.11</td>
	</tr>
	<tr>
		<td>WM</td>
		<td>SwayFX / Hyprland / niri</td>
	</tr>
	<tr>
		<td>Shell</td>
		<td>bash</td>
	</tr>
	<tr>
		<td>Terminal</td>
		<td>Foot</td>
	</tr>
	<tr>
		<td>Interface</td>
		<td>QuickShell</td>
	</tr>
	<tr>
		<td>Screen Locker</td>
		<td>Hyprlock</td>
	</tr>
	<tr>
		<td>Monitoring</td>
		<td>Btop</td>
	</tr>
	<tr>
		<td>Audio</td>
		<td>PipeWire</td>
	</tr>
	<tr>
		<td>Browser</td>
		<td>Zen browser</td>
	</tr>
	<tr>
		<td>File Manager</td>
		<td>ranger / yazi / dolphin</td>
	</tr>
	<tr>
		<td>Editor</td>
		<td>micro / helix</td>
	</tr>
	<tr>
		<td>Theme</td>
		<td>zenburn</td>
	</tr>
	<tr>
		<td>Icons</td>
		<td>Tela Gray</td>
	</tr>
	<tr>
		<td>Bootloader</td>
		<td>Grub</td>
	</tr>
	<tr>
		<td>Optimization</td>
		<td>Go binaries</td>
	</tr>
	<tr>
		<td>Accent changer</td>
		<td>wallust</td>
	</tr>
</table>

<div align="left">
	<h3>-- О проекте -- :</h3>
	<p>
  <i>JES</i> использует для отображения интерфейса <b>QuickShell</b>.<br>
  <br>
	Доступен <b>SwayFX / Hyprland / niri</b>, но <b>Niri</b> не имеет размытия, а также имеет баг с воркспейсами, скрипт работает с ним некорректно.<br>
  Также, отредактировав 3 скрипта-болванки, можно запустить данный интерфейс на любом wayland тайлинге С поддержкой subscribe протоколов для данных о воркспейсах, активном окне и раскладке.<br>
  <br>
	В проекте есть оптимизация, но он не тестировался на слабых пк.<br>
	Go бинарники используются для скриптов, где важна быстрая скорость считывания большого потока данных, за счёт этого нагрузка на ЦП в простое 7-11%, вместо 35-45%.<br>
  <br>
	<i>JES</i> проектировался под стационарные пк, что позволяет лучше его проработать под столь прекрасные машины.<br>
	Монитор автора - UWQHD (3440x1440), проверенные разрешения: QHD (2560x1440) и выше. (FHD (1920x1080) поддерживается экспереминтально)<br>
	На них панель не имеет проблем с расположением модулей.<br>
	<br>
	Проект использует bash с кастом выводом, быстрее обновляется для SwayFX, ведь он ориентирован на автора и его повседневное использование.<br>
	Этот же факт добавляет постоянности проекту, ведь пока автор занимается своими делами, проект будет эволюционировать и дальше улучшаться.<br>
	<br>
	Для более быстрой закачи автор решил не вкладывать сюда видеообои с картинок, оставив на них ссылку.<br>
	<br>
	Тема `zenburn` <b>не</b> распространяется на <i>JES</i>, а только на программы, tty (NixOS only) и прочее, у <i>JES</i> встроенная тема + поддержка base16 тем через base16.json<br>
	<br>
  <i>JES ориентирован не на тренды, а на практичность в повседневности и удобство.</i><br>
	</p>
	<h3>-- Дальнейший вектор -- :</h3>
	<p>
	<b>[c]</b> Добавление поддержки <b>Hyprland</b><br>
  <b>[c]</b> Добавление поддержки <b>Niri</b><br>
  <b>[p]</b> Создание установщика настроек<br>
	<b>[c]</b> Поддержка base16 тем в JES<br>
	<b>[p]</b> Создание виджета погоды<br>
	<b>[p]</b> Создание виджета календаря<br>
	c = completed; n = not completed; i = in progress; p = planned.<br> 
	</p>
</div>

> **Для кого *JES*?** 
> - Стационарные ПК с разрешением QHD+ (автор использует UWQHD)
> - Пользователи SwayFX / Hyprland (Niri в работе) или рукастые энтузиасты (сам shell работает на любом wm, но бинды и настройки тайлинга будут тогда отсутствовать)
> - Те, кто ценит производительность и архитектуру > тренды
> 
> Если вы попадаете в эту аудиторию — добро пожаловать. 
> Если нет — возможно, проект не для вас, и это нормально.

```
Если хочется живых видео обоев, то на выбор есть видеообои и шейдеры (последнее может плохо работать)
```
#### **Обои с скриншотов**: [тык](https://moewalls.com/lifestyle/touch-grass-live-wallpaper/)

## [структура *JES*](./structure_rus.md)

## -- Что меняется в *JES* --:
- `mainRad` - скругления, изначально - 10, работает идеально с параметрами 0-15
- `barOnTop` - панель управления вверху, а также прилежащие к ней виджеты, изначально включено
- `minibar` - скрывает cava, делает панель шириной 1920px, изначально выключено

## -- Комбинации клавиш -- :
| комбинация | что делает |
| :--- | :---: |
| `super + e` | файловый менеджер |
| `super + q` | терминал |
| `super + o` | Кнопки питания |
| `super + 1` или `super + scrll up \| scrll dwn` | переключение между р. столами |
| `super + shift + 1` или `super + shift + стрелки` | перенос программ между р. столами  |
| `super + пкм` | ресайз окон |
| `super + shift + стрелки` или `super + лкм` | перемещение окна |
| `super + стрелки` | переключение между окнами |
| `super + alt + лкм` | изменение типа окна: плавующий или в тайлинге |
| `super + w` | перезапуск интерфейса |
| `super + s` | полноэкранный снимок |
| `super + d` | снимок выделенной области |
| `super` | открыть лаунчер приложений |
| `super + g` | создать группу |
| `super + ctrl + g` | разгруппировать программы |
| `super + tab` | прошлый р. стол |
| `capslock` или `shift + alt` | смена языка |
| `shift + capslock` | включить \| выключить капс |
| `super + space` | раскрыть окно, поверх других |
| `ctrl + /` | воспроизвести \| остановить музыку |
| `ctrl + .` | следующий трек |
| `ctrl + ,` | предыдущий трек |
| `alt + pgup` | повысить яркость |
| `alt + pgdn` | понизить яркость |
| `alt + F9` | выключить звук |
| `alt + F10` | тише |
| `alt + F11` | громче |
| `alt + F12` | открыть \| закрыть проигрыватель |

## -- Как выглядит *JES* --:
### Рабочий стол
![alt_image](./images/1.webp)
![alt_image](./images/2.webp)

### Панель управления
![alt_image](./images/3.webp)

### Выбор обоев
![alt_image](./images/4.webp)

### Проигрыватель
![alt_image](./images/5.webp)
![alt_image](./images/6.webp)

### Кнопки питания
![alt_image](./images/7.webp)

### fastfetch
![alt_image](./images/8.webp)

### popup громкости и звука
![alt_image](./images/9.webp)

### Лаунчер приложений
![alt_image](./images/10.webp)

### блокировка экрана
![alt_image](./images/11.webp)
![alt_image](./images/12.webp)

### bash строка
```
1 [02:00 - orflem:~]$  cd gits/just_enough_shell/
2 [02:00 - orflem:~/gits/just_enough_shell main]$  
```
номер команды, дата, юзер, директория, состояние гита (при открытии проекта, связанный с git)

## -- Установка --:
### NixOS
```
1. Установите NixOS
2. сделайте бекап файлов системы (sudo mkdir -p /etc/nixos/backups && sudo cp /etc/nixos/* /etc/nixos/backups/*.backup)
3. переместите конфиг в "/etc/nixos" (sudo cp ./*.nix /etc/nixos/)
4. создайте бекап конфигов юзера (cp -r ~/.config/ ~/backups/ && cp ~/.bashrc ~/backups)
5. Доработайте конфиг NixOS под себя, учтите, что нужно вписать своего юзера в разделе "USER ACCOUNT", локализацию с регионом в "LOCALISATION" и доп. диски в "FILESYSTEMS" (если есть)
6. из ".config/" перекинуть файлы в "~/.config", а из ".local/" в "~/.local" (cp -r ./.local/* ~/.local/ && cp -r ./.config/* ~/.config/ && cp ./.bashrc ~/.bashrc)
7. sudo nixos-rebuild switch
8. введите reboot
```
### Arch Linux или Arch based
```
1. Установите Arch Linux (для простоты советую EndeavourOS)
2. Установите yay или paru (yay: git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si)
3. Установите официальный софт (sudo pacman -Syu && pacman -S $(cat ./arch_official.txt))
4. Установите юзер софт (yay -S $(cat ./arch_aur.txt))
5. Установите тему zenburn для qt и gtk
6. С помощью ИИ попытайтесь всю систему перекрасить в zenburn и поставить ter-v32n (пропустите, если вас не интересует результат 1 в 1, как на NixOS)
7. создайте бекап конфигов юзера (cp -r ~/.config/ ~/backups/ && cp ~/.bashrc ~/backups)
8. из ".config/" перекинуть файлы в "~/.config", а из ".local/" в "~/.local" (cp -r ./.local/* ~/.local/ && cp -r ./.config/* ~/.config/ && cp ./.bashrc ~/.bashrc)
9. введите reboot
```

## -- Лицензия --:
Уведомления были взяты из проекта [blxshell](https://github.com/binarylinuxx/dots) и модернизированы как визуально, так и частично технически, лицензия **GNU GPL v3**
Советую его посмотреть

Эти конфигурации распространяются под лицензией **GNU GPL v3**.

Простыми словами это значит:
- Вы можете свободно использовать, изучать и изменять этот код.
- Если вы делитесь своими изменениями или собранной на основе этого кодом с другими (например, выложили форк), вы **обязаны** сделать ваш исходный код также открытым и доступным для всех под этой же лицензией.

Это гарантирует, что все улучшения и производные работы останутся свободными и открытыми, как и оригинал.

Полный текст лицензии см. в файле [LICENSE](./LICENSE).

[![boosty](https://img.shields.io/badge/%D0%9F%D0%BE%D0%B4%D0%B4%D0%B5%D1%80%D0%B6%D0%B8_%D0%BD%D0%B0_boosty-8b3d30?style=for-the-badge&logo=boosty&logoColor=f5f5f5)](https://boosty.to/orflem.ru/)

##### Created by \_ORFLEM\_
