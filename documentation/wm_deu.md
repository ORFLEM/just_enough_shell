# Anleitung zur Erstellung eines WM-Adapters

- Im Ordner for-quickshell liegt der Ordner `CustomBar` — dies ist eine Vorlage für einen WM-Adapter
- In der Vorlage liegen 4 Skript-Vorlagen, deren Ausgabe bereits für JES vorbereitet ist; du musst nur die IPC-Befehle deines WM eintragen; der Befehlstyp ist der Subscribe-Modus mit JSON-Ausgabe
- Diese 4 Skript-Vorlagen dienen der Übertragung von Workspace-Daten, Koordinaten für 2D-Canvas-WMs, Tastaturbelegung und aktivem Fenster (es muss die App-ID übertragen werden)

- Der Autor akzeptiert PRs ins Core, aber für einen jeweiligen Adapter, der nicht vom JES-Autor stammt, ist der Absender des PR verantwortlich
- Es werden auch Issues/PRs angenommen, in denen darum gebeten wird, den eigenen WM in wm_repo einzutragen, und diese Variante ist **empfohlen**
- Bei Änderungen der Anbindungs-API informiert der Autor alle WM-Autoren in Issues über die Änderung seiner Anbindungs-API, wenn der WM in wm_repo eingetragen ist oder es sich um einen Core-Adapter handelt, der nicht vom JES-Autor stammt; im Issue wird es eine Erläuterung zum Update + eine neue Vorlage geben

- Die Vorlage ist für typische WMs mit Workspaces oder Koordinaten gemacht; wenn dein WM ein anderes System hat, teile es dem Autor in einem [Issue](https://github.com/ORFLEM/just_enough_shell/issues/new) mit, dann schreibt der Autor einen 3. Modus `custom`, der Text ausgibt, d. h. sofort fertigen Text
