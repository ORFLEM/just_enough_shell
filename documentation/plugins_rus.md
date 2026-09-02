# Инструкция по созданию плагинов

## Правило № 1
- Плагин **всегда** находится в своей отдельной папке

## Правило № 2
- Плагин **не** должен потреблять много ресурсов устройства, для оптимизации разрешается любой язык, но **рекомендован golang**

## Правило № 3
- название файлов в плагине кратко поясняют зачем он, а подключаемый файл **указываается в инструкции по установки плагина**
- Если плагин имеет сложный функционал в отдельном окне, то окно должно быть в lazyLoader

## Визуальная составляющая
- В плагине для главного фона испульзуется:
```qml
Rectangle {
    opacity: 0.85
    gradient: Gradient {
        orientation: Gradient.Horizontal
        GradientStop { position: 0.0; color: col.background3 }
        GradientStop { position: 0.05; color: col.background2 }
        GradientStop { position: 0.3; color: col.background1 }
        GradientStop { position: 0.7; color: col.background1 }
        GradientStop { position: 0.95; color: col.background2 }
        GradientStop { position: 1.0; color: col.background3 }
    }
}
```
- А для фона кнопки и прочего:
```qml
Rectangle {
    opacity: 0.65
    gradient: Gradient {
        orientation: Gradient.Horizontal
        GradientStop { position: 0.0; color: col.backgroundAlt2 }
        GradientStop { position: 0.275; color: col.backgroundAlt1 }
        GradientStop { position: 0.725; color: col.backgroundAlt1 }
        GradientStop { position: 1.0; color: col.backgroundAlt2 }
    }
}
```
- Для hover эффектов используется:
```qml
Item {
    id: button
    property bool hovered: false
    Rectangle {
        anchors.fill: parent
        radius: mainRad - root.margins
        opacity: 0.65
        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop { position: 0.0; color: col.backgroundAlt2 }
            GradientStop { position: 0.275; color: col.backgroundAlt1 }
            GradientStop { position: 0.725; color: col.backgroundAlt1 }
            GradientStop { position: 1.0; color: col.backgroundAlt2 }
        }
    }
    Rectangle {
        anchors.fill: parent
        anchors.margins: 2
        radius: mainRad - 2 - root.margins // складываем все margins
        color: button.hovered ? col.accent : "transparent" 
        Behavior on color { ColorAnimation { duration: 200 } }
    }
    // код
    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onEntered: {
            button.hovered = true
        }
        onExited: {
            button.hovered = false
        }
    }
}
```

#### фон можно использовать другой, в данном примере использовался фон для кнопок

- Для радиусов используется `radius: mainRad`, если делаете margins, то пишете в следующем блоке `radius: mainRad - <число_в_margin>`
- Все цвета берите из глобального объекта `col` (определён в `colors.json` и доступен через `shell.qml`).
- Также JES поддерживает base16 темы (`base.base<01-16>`)
- шрифт устанавливается с помощью **fontFamily** и **fontSize**
- у JES есть 2 accent цвета - тёмный и светлый

## Передача данных в интерфейс
- Использовать для постоянного потока (рекомендуется для произовдительности этот метод) `JsonListen`, а для разового запроса раз в опр. время `JsonPoll`
- Данные передаются в json виде, для визуальных программ без функций - просто строка (например, cava в баре)
- Данные о WM передаются через параметр `wm_connect`, если вам нужны данные о координатах/воркспейсах/активной программе/раскладке - вызываем `wm_connect`, а какие данные можно из него взять - см. `BaseBar.qml`.

## Библиотеки JES
- для упрощения создания плагинов, были созданы библиотеки `JES.Helpers` и `JES.Bar` - первый требуется для вызовов `JsonListen`, `JsonPoll` и `MarqueeText`, а второй - для интеграции с `BaseBar.qml`, т.е. для создания плагинов по подключению WMs к JES (см. ниже)

### Если что-то непонятно, то смотрите файл `baseBar.qml` в папке bar, это визуальный эталон для всего ui

## Подключения плагина к JES

для подключения к JES у плагина должен быть `manifest.json`, ниже приведён максимальный базовый вариант для JES без сторонних расширений:
```json
{
  "api_version": "0.1.1",
  "plugin_version": "1.0",
  "name": "plugin name",
  "api_request": [
    "launcher",
    "plugin_center",
    "osd",
    "Jwindow",
    "wm_connect"
  ],
  "main_source": "Main.qml",
  "json_files": {
    "launcher": "launch_list.json",
    "plugin_center": "load_list.json",
    "osd": "osd_list.json",
    "Jwindow": "Jwindow.json"
  }
}
```

Для активации плагина в `config.toml` в `~/.config/JES/` надо указать следующие моменты:
```toml
[[plugin]]
name = "plugin name" # data in property name from manifest.json
active = true
```


## Подключение к лаунчеру JES
- Для подключения к лаунчеру мы используем json файл с такой структурой:
```json
{
  "name": "tab",
  "icon": "",
  "placeholder": "Search in tab...",
  "info": [
    {
      "id": "app_1",
      "name": "app 1",
      "exec": "script launch $id"
    },
    {
      "id": "2",
      "name": "take screenshot",
      "exec": "grim ~/screenshots"
    }
  ]
}
```

- В `info` мы можем передавать любой список, содержащий следующие моменты: `{"id", "name", "icon", "exec"}` - это названия параметров json.

- В `id` мы передаём нужный параметр для скрипта или порядковый номер, обязательно string версия
- В `name` текст, что будет отображаться в блоке
- В `icon` значёк при его наличии
- В `exec` команда, которая будет выполняться, если используется id, то вызвать его в команде можно, как `$id`, который берётся из id, указанного в json

### `id` не обязателен, если вы указываете полные команды для объекта. Он требуется, если вы создали скрипт, что должен запускать разные объекты.

## Подключение к центру плагинов JES
- Для подключения к центру плагинов мы используем json файл с такой структурой:
```json
[
    {"source": "Content.qml", "colSpan": 1, "rowSpan": 1}
]
```

- максимальные размеры - `colSpan: 3, rowSpan: 7`
- в source можно передавать любой модуль

## Подключение к osd JES
- Для подключения к osd мы используем json файл с следующей структурой:
```json
[
  {
    "id": "mic_volume",
    "type": "percent",
    "command": "./mic.sh"
  },
  {
    "id": "media_status",
    "type": "text",
    "command": "./media.sh"
  }
]
```
- type отвечает за формат отображения: `text` - отображение текстовой информации, `precent` - отображение полосы и процентной информации, в начале можно поставить иконку
- в command мы передаём скрипты, которые выводят для `text` - текстовое сообщение:
  ```json
  {
      "text": "hi"
  }
  ```
  а для `precent` мы передаём:
  ```json
  {
      "value": 55,
      "sign": "󱄅"
  }
  ```

## Подключение к Jwindow JES
- Для подключения у Jwindow мы также используем Jsonw, с следующей информацией:
```json
[
 {
      "name": "API Test",
      "source": "JwindowTabTester.qml"
  }
]
```
- в source, как и в плагин центре, можно указать любой модуль, но максимальные размеры ограничены fhd

## Подключение других WMs в JES
- В `manifest.json` мы укзаваем в `api_request` - `wm_connect`, чтобы система подняла не только сам плагин, но и данные из панели, чтобы можно было обращаться к WM данным.
- Для подключения WMs в JES я в `for-documentation` оставил example плагин, где даётся шаблон для подключения других wm, достаточно дописать пару команд в скрипты и всё.

## Расширение API JES
- для расширения API, ваш плагин должен подписаться на главный кэш всей плагин системы:
```qml
FileView {
    id: pluginView
    path: Quickshell.env("HOME") + "/.cache/JES_plugin_list.json"
    watchChanges: true
    onFileChanged: reload()
    onLoaded: {
        yourFunction(text())
    }
}
```
 и после в функции мы прописываем нужные задачи для проверки, включая проверку флага api_reqest на требуемый запрос

### если вы интегрируете новый функционал для api, то ваш плагин должен вызывать notify-send с предупреждением или warning плашку показать, что API был расширен таким-то плагином
