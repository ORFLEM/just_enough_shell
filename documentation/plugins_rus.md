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
        radius: mainRad - 3
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
        radius: mainRad - 5 // складываем все margins
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

## Если что-то непонятно, то смотрите файл BaseBar.qml в папке bar, это визуальный эталон для всего ui
