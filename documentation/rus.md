<div align="center">
	<img src="https://img.shields.io/github/last-commit/ORFLEM/just_enough_shell?&style=for-the-badge&color=bbbbbb&label=Последний%20коммит&logo=git&logoColor=D9E0EE&labelColor=1E202B" alt="GitHub last commit">
    <img src="https://img.shields.io/github/repo-size/ORFLEM/just_enough_shell?color=bbbbbb&label=Размер%20проекта&logo=protondrive&style=for-the-badge&logoColor=D9E0EE&labelColor=1E202B" alt="Repository size">
    <img src="https://img.shields.io/github/stars/ORFLEM/just_enough_shell?color=bbbbbb&label=Звёзды%20проекта&logo=andela&style=for-the-badge&logoColor=D9E0EE&labelColor=1E202B" alt="Repository size">
	<img src="./images/preview.webp" width="900px">
	<h1>> Just Enough Shell _</h1>
	<p>Создан для повседневности, не для картинок.</p>
</div>

***

<div align="left">
	<h3>-- О проекте -- :</h3>
	<p>
	<i>JES</i> - WM-agnostic rolling release desktop shell, поддерживающий подключение любого wm нативно, даже самописных.<br>
  <br>
	<i>JES</i> поддерживает из коробки:
	<ul>
  	<li><a href="https://github.com/wlrfx/swayfx">SwayFX</a></li>
  	<li><a href="https://hypr.land/">Hyprland</a></li>
  	<li><a href="https://github.com/niri-wm/niri">Niri</a></li>
		<li><a href="https://github.com/malbiruk/driftwm">DriftWM</a></li>
		<li><a href="https://github.com/binarylinuxx/zwwm">ZWWM</a></li>
		<li>Любой другой через плагин систему (см. <a href="./plugin_repo.md">plugin_repo.md</a>)</li>
	</ul>
	<br>
	В проекте есть оптимизация, но он не тестировался на <b>очень</b> слабых пк.<br>
	Go бинарники используются для скриптов, где важна быстрая скорость считывания большого потока данных, за счёт этого нагрузка на ЦП в простое у <i>JES</i> - 1-2% ЦП и ~450мб ОЗУ, вместо 35-45%.<br>
  <br>
	Проект имеет простую систему плагинов, что делает его расширяемым.<br>
	<br>
	<i>JES</i> проектировался под стационарные пк, из-за чего бывают архитектурные проблемы с ноутбуками.<br>
	Проверенные разрешения: FHD (1920x1080) и выше.<br>
	На них панель не имеет проблем с расположением модулей.<br>
	Нативно поддерживается несколько мониторов.<br>
	<br>
	Проект переживал смену с eww на qs и не будет заброшен, ведь неразрывно связан с поседневом автора и запросами комьюнити, он будет эволюционировать и дальше улучшаться.<br>
	<br>
  <i>JES ориентирован не на тренды, а на практичность в повседневности и удобство.</i><br>
	</p>
	<h3>-- благодарности -- :</h3>
	<p>
	Спасибо <b><a href="https://github.com/binarylinuxx/dots">Blxshell</a> и его автору</b> за помощь с изучиением Quickshell, домен сайта.<br>
	Спасибо <b><a href="https://github.com/f026/">f026</a></b> за <a href="https://github.com/f026/activate-linux-plugin">первый плагин</a> для JES.<br>
	Спасибо <b><a href="https://github.com/malbiruk/driftwm">автору DriftWM (malbiruk)</a></b> за помощь с IPC DriftWM, добавлением новых функций в WM для JES и в принципе лояльности к проекту.<br>
  Спасибо <b><a href="https://github.com/frosti-4">frosti-4</a></b> за скрипт для Arch linux.<br>
  Спасибо <b><a href="https://github.com/Gegs8">Gegs8</a></b> за нахождение багов установщика.<br>
	</p>
	<h3>-- Дальнейший вектор -- :</h3>
	<p>
  <b>[c]</b> Разработка api для работы с launcher<br>
  <b>[c]</b> Разработка api для работы с plugin center<br>
	<b>[c]</b> Создание виджета погоды<br>
	<b>[c]</b> Создание полноценного api<br>
	<b>[c]</b> Установка JES через flake<br>
	<b>[c]</b> Переработка подкпатоной части<br>
	<b>[c]</b> Новый метод подключения кастом wm<br>
	<b>[c]</b> Новый формат плагинов<br>
	<b>[i]</b> Развитие комьюнити и инфраструктурной части<br>
	<b>[i]</b> Системный модуль `CoreAura` контроля состояния ПК (ошибки ядра, падения сервисов, мониторинг нагрузки)<br>
  <b>[n]</b> Разработка api для работы с bar<br>
	<b>[n]</b> Выбор темы тёмная/светлая<br>
	c = completed; n = not completed; i = in progress; p = planned.<br>
	</p>
</div>

Посмотреть прошлые задачи, выполненные - [complited.md (eng only)](./complited.md)

> **Для кого *JES*?** 
> - Стационарные ПК с разрешением FHD+ (автор использует UWQHD - 3440x1440 и считает его эталоном для проекта)
> - Пользователи SwayFX / Hyprland / Niri / DriftWM / ZWWM или энтузиасты с временем на первичную настройку (сам shell работает на любом wm, но бинды и настройки тайлинга будут тогда отсутствовать)
> - Разработчик WM, которому нужно базовое окружение под wm без месячно работы с waybar, rofi и прочими программами
> - Те, кто ценит производительность и архитектуру выше трендов
> - Нужен приятный и легковесный для цп/озу интерфейс
> 
> Если вы попадаете в эту аудиторию — добро пожаловать. 
> Если нет — возможно, проект не для вас, и это нормально.

## -- ВАЖНО -- :
- Все тесты производительности производились на r7 5700x и r5 3600, на обоих ЦП процент был одинаков: 1-2%, но лучше уточнать через ии или сайты сравнения мощность своего цп для понимания приблизительной нагрузки
- Nvidia видеокарты работают УЖАСНО, **всё моментально может завсинусть из-за ничего**, автор не собирается этот вопрос решать, так как это **пробелмы на стороне драйверов**!
- Автор не имеет опыта работы с Arch Linux, установка на Arch может быть неккоректной, если так и есть, просьба описать проблему в Issue, а по возможности предложить фикс
- Установка находится в самом низу
- Автор открыт к предложениям и помогает с освоением проекта, в случае проблем, писать в [Issue](https://github.com/ORFLEM/just_enough_shell/issues/new)
- Автор будет благодарен за помощь с поддержкой других дистрибутивов и сразу примет новые pull requests с указанием автора, сделавший поддержку, востребованны такие, как void linux, alt linux и debian.

## [структура *JES*](./structure_rus.md)

## -- Что меняется в *JES* --:
- `wm` -                      auto, но для подключения WM не из списка доступных надо прописывать название с большой буквы
- `wm_type` -                 auto, но для WM не из списка доступных на выбор workspaces или coordinates
- `mainRad` -                 скругления, изначально - 10, работает идеально с параметрами 0-25
- `barOnTop` -                панель управления вверху, а также прилежащие к ней виджеты, изначально включено
- `minibar` -                 делает панель шириной 1920px, изначально выключен
- `BarHeight` -               высота панели, изначально 30
- `fontSize` -                размер шрифта, изначально 17
- `fontFamily` -              шрифт, изначально Mononoki Nerd Font Propo
- `custom_wallpaper_engine` - выключить встроенные обои, изначально false
- `disableGenerate` -         переключение JES matugen темы на base16, изначально false
- `doNotDisturb` -            тихий режим, изначально false
- `timezone` -                город виджета погоды, изначально не присутствует, берётся данные из `user-config.toml` конфигурации NixOS
- `animation` -               скорость анимаций, float число, изначально 1.0
- `wtw` -                     расстояние от виджета до виджета, изначально 6
- `spacing` -                 расстояние между блоками внутри виджета, изначально 3
- `margins` -                 отступы в виджетах, изначально 3
- `disableCorners` -          отключение скруглений монитора, изначально отключено
- `openweather_key` -         ключ для openweather api, без изначальных данных
- `do_not_sync_rad` -         не синхронизировать радиусы wm с радиусом jes, изначально false
- `changeShader` -            заменить дефолтный шейдер на другой, изначально пустой, но туда нужно вводить путь до **qsb** файла
- `nanoPlayer` -              компактный режим плеера в bar, изначально false
- `nanoPlrSize` -             размер компактного плеера, изначально 200
- `disableCava` -             отключить эквалайзер в bar, изначально false
- `enableFolders` -           включить запуск плагинов в формате папки, изначально false

```
Важно, config.toml лежит в папке JES (~/.config/JES/)
также его можно изменять, вызвав:
	jes-cli editConf
в jes-cli для редакции конфига используется micro, для выхода используйте Ctrl+Q, а для сохранения - Ctrl+S
```

## -- Как выглядит *JES* --:
### Панель управления
![alt_image](./images/1.webp)
![alt_image](./images/2.webp)

### Выбор обоев
![alt_image](./images/3.webp)

### Проигрыватель
![alt_image](./images/4.webp)
![alt_image](./images/5.webp)

### Кнопки питания
![alt_image](./images/6.webp)

### Jwindow
![alt_image](./images/7.webp)

### popup громкости и звука
![alt_image](./images/8.webp)

### Лаунчер приложений
![alt_image](./images/9.webp)

### блокировка экрана
![alt_image](./images/10.webp)
![alt_image](./images/11.webp)

\* Скриншоты сделаны на [дотфайлах автора](https://github.com/ORFLEM/dots)

## -- Плагины --:
### Установка
```
1. откройте ~/.config/JES/
2. закиньте папку с плагином
3. откройте config.toml
4. впишите данные строки:
   [[plugin]]
   name = "plugin name" # data in property name from manifest.json
   active = true
```

### [Подробная инструкция создания плагинов](./plugins_rus.md)

### [Репозиторий плагинов](./plugin_repo.md)
### Важно: репозиторий только на английском, ввиду того, что на эту часть сильно влияет комьюнити проекта, и переводить все краткие описания на разные языки - невыносимо трудно

## -- Установка JES --:
### NixOS
- в `flake` укажите следующее:
```nix
{
	inputs = {
    jes.url = "github:ORFLEM/just_enough_shell";
	}
	outputs = { your inputs, jes, ... }@inputs:
  let
    system = "x86_64-linux";
    hostname = "nixos";

    specialArgs = { inherit inputs system hostname; };

  in {
    nixosConfigurations.${hostname} = nixpkgs.lib.nixosSystem {
      inherit system specialArgs;
      modules = [
				jes.nixosModules.default
			];
		};
	};
}
```
- пересобeрите flake
- в `configuration.nix` укажите
```nix
services.jes = {
  enable = true;
  users = [ "your user" ];
};
```
- пересоберите NixOS

### Arch Linux или Arch based (может быть неккоректной, в случае проблем, писать в [Issue](https://github.com/ORFLEM/just_enough_shell/issues/new))
- Установите Arch Linux (для простоты советую EndeavourOS)
<!-- - Запустите установщик (не переработан): -->
<!-- ```bash -->
<!-- git clone https://github.com/ORFLEM/just_enough_shell.git && cd just_enough_shell && ./install_arch.sh -->
<!-- ``` -->

<!-- - В случае ошибок устанавливайсте вручную: -->
- Установка доступна только ручная, автоматическая сломана:
```
1. Установите Arch Linux (для простоты советую EndeavourOS)
2. Установите yay или paru (yay: git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si)
3. Установите официальный софт (sudo pacman -Syu && pacman -S $(cat ./installer/arch_official.txt))
4. Установите юзер софт (yay -S $(cat ./installer/arch_aur.txt))
```

## -- Лицензия --:
Уведомления были взяты из проекта [blxshell](https://github.com/binarylinuxx/dots) и модернизированы как визуально, так и частично технически, лицензия уведомлений - **GNU GPL v3**
Советую его посмотреть

Эти конфигурации распространяются под лицензией **BSD 3-Clause License**.

Простыми словами это значит:
- Вы можете что угодно делать с кодом, но автор держит на проект авторские права.
- Вы обязаны указать исходный проект и автора в форке, даже если он закрыт по коду.
- Вы не можете использовать для продвижения своей версии проекта лицо (никнейм, прочие упоминания) автора без его разрешения.

Это гарантирует, что имя автора и проект всегда будут указаны, а имя автора не станет инструментом продвижения чужих форков.

Полный текст лицензии см. в файле [LICENSE](./LICENSE).

##### Created by [\_ORFLEM\_](https://github.com/ORFLEM)
