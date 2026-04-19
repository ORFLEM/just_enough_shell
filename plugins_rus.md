# Инструкция по созданию плагинов

## Правило № 1
- Плагин **всегда** находится в своей отдельной папке

## Правило № 2
- Плагин **не** должен потреблять много ресурсов устройства, для оптимизации разрешается любой язык, но **рекомендован golang**

## Правило № 3
- название файлов в плагине кратко поясняют зачем он, а подключаемый файл **указываается в инструкции по установки плагина**
- Если плагин имеет сложный функционал в отдельном окне, в инструкции должен быть готовый LazyLoader для загрузки окна

## Визуальная составляющая
- В плагине для главного фона испульзуется:
```qml
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
```
- А для фона кнопки и прочего:
```qml
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
Rectangle {
    id: <название_какое_то_смысловое>
    anchors.fill: parent
    anchors.margins: 2
    radius: mainRad - <margins_до_плюс_margin_в_этом_модуле>
    color: "transparent"
    Behavior on color { ColorAnimation { duration: 200 } }
}
// код
MouseArea {
    anchors.fill: parent
    hoverEnabled: true
    onEntered: {
        <название_какое_то_смысловое>.color = col.accent
    }
    onExited: {
        <название_какое_то_смысловое>.color = "transparent"
    }
}
```
- Для радиусов используется `radius: mainRad`, если делаете margins, то пишете в следующем блоке `radius: mainRad - <число_в_margin>`
- Все цвета берите из глобального объекта `col` (определён в `colors.json` и доступен через `shell.qml`).
- Допускается использование жёстких цветов, если требуется, но он **обязательно** берётся из zenburn темы
- Основной шрифт: `Mononoki Nerd Font Propo` размером **17px**

## Передача данных в интерфейс
- Использовать для постоянного потока (рекомендуется для произовдительности этот метод) `JsonListen`, а для разового запроса раз в опр. время `JsonPoll`
- Данные передаются в json виде, для визуальных программ без функций - просто строка (например, cava в баре)

## Если что-то непонятно, то смотрите файл BaseBar.qml в папке bar, это визуальный эталон для всего ui
