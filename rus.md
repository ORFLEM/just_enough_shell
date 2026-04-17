![last_commit](https://img.shields.io/github/last-commit/ORFLEM/orflem_nixos_configs?&style=for-the-badge&color=bbbbbb&label=Последний%20коммит&logo=git&logoColor=D9E0EE&labelColor=1E202B)
![repo_size](https://img.shields.io/github/repo-size/ORFLEM/orflem_nixos_configs?color=cccccc&label=Размер%20проекта&logo=protondrive&style=for-the-badge&logoColor=D9E0EE&labelColor=1E202B)

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
		<td>swayfx</td>
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
	Доступен <b>SwayFX</b>, но идут работы над добавлением поддержки <b>Hyprland и Niri</b>.<br>
  Также, отредактировав 3 скрипта-болванки, можно запустить данный интерфейс на любом wayland тайлинге С поддержкой subscribe протоколов для данных о воркспейсах, активном окне и раскладке.<br>
  <br>
	В проекте есть оптимизация, но он не тестировался на слабых пк.<br>
	Go бинарники используются для скриптов, где важна быстрая скорость считывания большого потока данных, за счёт этого нагрузка на ЦП в простое 5-7%, вместо 35-45%.<br>
  <br>
	<i>JES</i> проектировался под мониторы с разрешением UWQHD (3440x1440), проверенные разрешения: QHD (2560x1440) и выше.<br>
	На них панель не имеет проблем с расположением модулей.<br>
	<br>
  <i>JES ориентирован не на тренды, а на практичность в повседневности и удобство.</i><br>
	</p>
	<h3>-- Дальнейший вектор -- :</h3>
	<p>
	<b>[i]</b> Добавление поддержки <b>Hyprland</b><br>
  <b>[p]</b> Добавление поддержки <b>Niri</b><br>
  <b>[p]</b> Создание установщика настроек<br>
	<b>[p]</b> Создание виджета погоды<br>
	<b>[p]</b> Создание виджета календаря<br>
	c = completed; n = not completed; i = in progress; p = planned.<br> 
	</p>
</div>

>[!WARNING]
> **Конфигурации предназначены для СТАЦИОНАРНОГО компьютера!**
> - Конфиги включают спорные или консервативные решения (bash вместо fish/zsh, приоритет на SwayFX)
> - Апдейты будут приходить раньше на SwayFX, т.к. это мой основной WM, и проект неразрывно связан с моим повседневным использованием.
> - Конфиги включают **только статические** обои, изображение в репозитории визуально может отличаться от получаемых конфигов из-за других обоев!
> - Все настройки точно работают на UWQHD (3440x1440) мониторах или мониторах с разрешением от QHD, на других могут работать хуже.
> - Основная тема зафиксирована, с обоев берётся только акцент для интерфейса.
<!-- > - Hyprland без доработок работает только на NixOS -->
<!-- > - Плагин hy3 отсутствует в репозиториях ALT Linux -->

```
Если хочется живых видео обоев, то на выбор есть видеообои и шейдеры (последнее может плохо работать)
```
#### **Обои с скриншотов**: [тык](https://moewalls.com/lifestyle/touch-grass-live-wallpaper/)

## [структура *JES*](./structure_rus.md)

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

## -- Установка --:
```
1. Установите NixOS
2. сделайте бекап файлов системы (sudo mkdir -p /etc/nixos/backups && sudo cp /etc/nixos/* /etc/nixos/backups/*.backup)
3. переместите конфиг в "/etc/nixos" (sudo cp ./*.nix /etc/nixos/)
4. создайте бекап конфигов юзера (cp -r ~/.config/ ~/backups/)
5. Доработайте конфиг NixOS под себя, учтите, что нужно вписать своего юзера в разделе "USER ACCOUNT", локализацию с регионом в "LOCALISATION" и доп. диски в "FILESYSTEMS" (если есть)
6. из ".config/" перекинуть файлы в "~/.config", а из ".local/" в "~/.local" (cp -r ./.local/* ~/.local/ && cp -r ./.config/* ~/.config/)
7. sudo nixos-rebuild switch
```

## -- Лицензия --:
Уведомления были взяты из проекта [blxshell](https://github.com/binarylinuxx/dots) и модернизированы как визуально, так и частично технически, лицензия неизвестна

Эти конфигурации распространяются под лицензией **GNU GPL v3**.

Простыми словами это значит:
- Вы можете свободно использовать, изучать и изменять этот код.
- Если вы делитесь своими изменениями или собранной на основе этого кодом с другими (например, выложили форк), вы **обязаны** сделать ваш исходный код также открытым и доступным для всех под этой же лицензией.

Это гарантирует, что все улучшения и производные работы останутся свободными и открытыми, как и оригинал.

Полный текст лицензии см. в файле [LICENSE](./LICENSE).

[![boosty](https://img.shields.io/badge/%D0%9F%D0%BE%D0%B4%D0%B4%D0%B5%D1%80%D0%B6%D0%B8_%D0%BD%D0%B0_boosty-8b3d30?style=for-the-badge&logo=boosty&logoColor=f5f5f5)](https://boosty.to/orflem.ru/)

##### Created by \_ORFLEM\_
