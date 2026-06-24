<div align="center">
	<img src="https://img.shields.io/github/last-commit/ORFLEM/just_enough_shell?&style=for-the-badge&color=bbbbbb&label=Последний%20коммит&logo=git&logoColor=D9E0EE&labelColor=1E202B" alt="GitHub last commit">
  <img src="https://img.shields.io/github/repo-size/ORFLEM/just_enough_shell?color=bbbbbb&label=Размер%20проекта&logo=protondrive&style=for-the-badge&logoColor=D9E0EE&labelColor=1E202B" alt="Repository size">
  <img src="https://img.shields.io/github/stars/ORFLEM/just_enough_shell?color=bbbbbb&label=Звёзды%20проекта&logo=andela&style=for-the-badge&logoColor=D9E0EE&labelColor=1E202B" alt="Repository size">
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
		<td>NixOS 26.05</td>
	</tr>
	<tr>
		<td>WM</td>
		<td>SwayFX / Hyprland / niri / DriftWM</td>
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
		<td>theme changer</td>
		<td>matugen</td>
	</tr>
</table>

<div align="left">
	<h3>-- О проекте -- :</h3>
	<p>
  <i>JES</i> использует для отображения интерфейса <b>QuickShell</b>.<br>
  <br>
	<i>JES</i> поддерживает:
	<ul>
  	<li>SwayFX</li>
  	<li>Hyprland</li>
  	<li>Niri</li>
		<li>DriftWM</li>
		<li>Любой другой через 3 скрипта и один qml файл</li>
	</ul>
	<b>Niri</b> не имеет прозрачности и у него баг с воркспейсами на панели ввиду его архитектуры.<br>
	<br>
	В проекте есть оптимизация, но он не тестировался на слабых пк.<br>
	Go бинарники используются для скриптов, где важна быстрая скорость считывания большого потока данных, за счёт этого нагрузка на ЦП в простое 7-11%, вместо 35-45%.<br>
  <br>
	Проект имеет простую систему плагинов, что делает его расширяемым.<br>
	<br>
	<i>JES</i> проектировался под стационарные пк, что позволяет лучше его проработать под столь прекрасные машины.<br>
	Монитор автора - UWQHD (3440x1440), проверенные разрешения: FHD (1920x1080) и выше. (FHD (1920x1080) поддерживается нативно, <b>но</b> при включённом minibar могут быть баги, так как размер не меняется а модель отображения - да)<br>
	На них панель не имеет проблем с расположением модулей.<br>
	Нативно поддерживается несколько мониторов.<br>
	<br>
	Проект использует bash с кастом выводом, быстрее обновляется для SwayFX и DriftWM, ведь он ориентирован на автора и его повседневное использование.<br>
	Этот же факт добавляет постоянности проекту, ведь пока автор занимается своими делами, проект будет эволюционировать и дальше улучшаться.<br>
	<br>
	Для более быстрой загрузки автор решил не вкладывать сюда видеообои с картинок, оставив на них ссылку.<br>
	<br>
	Тема <i>zenburn</i> <b>не</b> распространяется на <i>JES</i>, а только на программы, tty (NixOS only) и прочее, у <i>JES</i> встроенная генерируемая тема + поддержка base16 тем через base16.json<br>
	<br>
  <i>JES ориентирован не на тренды, а на практичность в повседневности и удобство.</i><br>
	</p>
	<h3>-- Дальнейший вектор -- :</h3>
	<p>
	<b>[c]</b> Добавление поддержки <b>Hyprland</b><br>
  <b>[c]</b> Добавление поддержки <b>Niri</b><br>
	<b>[c]</b> Добавление поддержки <b>DriftWM</b><br>
	<b>[c]</b> Поддержка base16 тем в JES<br>
  <b>[c]</b> Мягкий material you<br>
	<b>[c]</b> Вывод информации об уст-ве, подключённое через kdeconnect<br>
	<b>[c]</b> Красивый screen picker<br>
	<b>[c]</b> Анимированная обложка в плеере, когда нету обложки<br>
	<b>[c]</b> Защита от статических обоев с неверным форматом в wallpaper picker<br>
	<b>[c]</b> Создание виджета календаря<br>
	<b>[c]</b> Поддержка нескольких мониторов<br>
  <b>[c]</b> Создание установщика настроек<br>
	<b>[c]</b> Выбор стиля нейтральный/яркий<br>
	<b>[i]</b> Popup миникарта для <b>driftwm</b><br>
	<b>[i]</b> Перевод <b>Hyprland</b> на lua конфиги<br>
	<b>[i]</b> Фикс <b>Niri</b><br>
	<b>[p]</b> Создание виджета погоды<br>
	<b>[n]</b> Выбор темы тёмная/светлая<br>
	c = completed; n = not completed; i = in progress; p = planned.<br> 
	</p>
</div>

> **Для кого *JES*?** 
> - Стационарные ПК с разрешением FHD+ (автор использует UWQHD)
> - Пользователи SwayFX / Hyprland / Niri / DriftWM или энтузиасты с временем на первичную настройку (сам shell работает на любом wm, но бинды и настройки тайлинга будут тогда отсутствовать)
> - Те, кто ценит производительность и архитектуру выше трендов
> - Нужен приятный и легковесный для цп/гпу интерфейс
> 
> Если вы попадаете в эту аудиторию — добро пожаловать. 
> Если нет — возможно, проект не для вас, и это нормально.

## -- ВАЖНО -- :
- Nvidia видеокарты работают УЖАСНО, **всё моментально может завсинусть из-за ничего**, автор не собирается этот вопрос решать, так как это **пробелмы на стороне драйверов**!
- Автор не имеет опыта работы с Arch Linux, установка на Arch может быть неккоректной, если так и есть, просьба описать проблему в Issue, а по возможности предложить фикс
- Установка находится в самом низу
- Автор открыт к предложениям и помогает с освоением проекта, в случае проблем, писать в [Issue](https://github.com/ORFLEM/just_enough_shell/issues/new)

```
Если хочется живых видео обоев, то на выбор есть видеообои и шейдеры (последнее может плохо работать с автогенерацией темы JES)
```
#### **Обои с скриншотов**: [тык](https://moewalls.com/lifestyle/touch-grass-live-wallpaper/)

## [структура *JES*](./structure_rus.md)

## -- Что меняется в *JES* --:
- `wm` - auto, но для подключения WM не из списка доступных надо прописывать название с большой буквы
- `wm_type` - auto, но для WM не из списка доступных на выбор workspaces или coordinates
- `mainRad` - скругления, изначально - 10, работает идеально с параметрами 0-25
- `barOnTop` - панель управления вверху, а также прилежащие к ней виджеты, изначально включено
- `minibar` - делает панель шириной 1920px, изначально выключен
- `BarHeight` - высота панели, изначально 30
- `fontSize` - размер шрифта, изначально 17
- `fontFamily` - шрифт, изначально Mononoki Nerd Font Propo
- `custom_wallpaper_engine` - выключить встроенные обои, изначально false
- `disableGenerate` - переключение JES matugen темы на base16, изначально false
- `doNotDisturb` - тихий режим, изначально false
- `timezone` - город виджета погоды, изначально не присутствует, берётся данные из `user-config.toml` конфигурации NixOS

```
Важно, config.toml лежит в папке Quickshell (~/.config/quickshell/)
в .bashrc автор оставил alias, если лень прописывать, достаточно вписать в консоль:
	edit-JES
в alias используется micro, для выхода используйте Ctrl+Q, а для сохранения - Ctrl+s
```

## [JES для DriftWM](./DriftWM_rus.md)

## -- Комбинации клавиш для SwayfX, Hyprland и Niri -- :
| комбинация | что делает |
| :--- | :---: |
| `super + e` | файловый менеджер |
| `super + q` \| `super + enter` | терминал |
| `super + p` | Кнопки питания |
| `super + 1-0` или `super + scrll up \| scrll dwn` | переключение между р. столами |
| `super + shift + 1-0` или `super + shift + стрелки` | перенос программ между р. столами  |
| `super + пкм` | ресайз окон |
| `super + shift + стрелки` или `super + лкм` | перемещение окна |
| `super + стрелки` | переключение между окнами |
| `super + alt + лкм` | изменение типа окна: плавающий или в тайлинге |
| `super + w` | перезапуск интерфейса |
| `home` | полноэкранный снимок |
| `shift + home` | снимок выделенной области |
| `super + d` | открыть лаунчер приложений |
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

### выбор кнопки для снимков вынесен вверх, т.к. не всем удобен home или он может отсутствовать, как у автора на клавиатуре print screen

### [Комбинации клавиш для DriftWM](./DriftWM_rus.md)

## -- Как выглядит *JES* --:
### Рабочий стол
![alt_image](./images/1.webp)
![alt_image](./images/2.webp)

### Панель управления (DriftWM версия отличается, см. [`DriftWM_rus.md`](./DriftWM_rus.md))
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

## -- Плагины --:
### Установка
```
1. откройте ~/.config/quickshell/
2. закиньте папку с плагином
3. откройте config.toml
4. впишите данные строки:
   [plugin.plugin-name]
   source = "папка плагина/Главный файл плагина.qml"
   active = true
```

### [Подробная инструкция создания плагинов](./plugins_rus.md)

### [Репозиторий плагинов](./plugin_repo.md)
### Важно: репозиторий только на английском, ввиду того, что на эту часть сильно влияет комьюнити проекта, и переводить все краткие описания на разные языки - невыносимо трудно

## -- Установка JES --:
### NixOS

- Установите NixOS
- запустите установщик:
  ```bash
  nix-shell -p git --run "git clone https://github.com/ORFLEM/just_enough_shell.git && cd just_enough_shell && ./install.sh"
  ```
- перезапуститесь `reboot`

### Arch Linux или Arch based (может быть неккоректной, в случае проблем, писать в [Issue](https://github.com/ORFLEM/just_enough_shell/issues/new))
```
1. Установите Arch Linux (для простоты советую EndeavourOS)
2. Установите yay или paru (yay: git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si)
3. Установите официальный софт (sudo pacman -Syu && pacman -S $(cat ./arch_official.txt))
4. Установите юзер софт (yay -S $(cat ./arch_aur.txt))
5. Установите тему zenburn для qt и gtk
6. При желании можно настроить системные темы (GTK/Qt) под zenburn и установить шрифт ter-v32n
7. создайте бекап конфигов юзера (cp -r ~/.config/ ~/backups/ && cp ~/.bashrc ~/backups)
8. из ".config/" перекинуть файлы в "~/.config", а из ".local/" в "~/.local" (cp -r ./.local/* ~/.local/ && cp -r ./.config/* ~/.config/ && cp ./.bashrc ~/.bashrc)
9. введите reboot
```
> Скрипт будет только под NixOS, если хочется скрипт под arch, просьба дать готовый скрипт, автор его вложит в проект

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
