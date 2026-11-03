# WM adapter creation guide

- the `CustomBar` folder in for-quickshell is a stub for a WM adapter
- the stub contains 4 script templates whose output is already prepared for JES; you only need to enter your WM's IPC commands; the command type is subscribe mode with JSON output
- these 4 script templates are used to pass workspace data, coordinates for 2D-canvas WMs, keyboard layout, and the active window (the app id must be passed)

- The author accepts PRs into core, but whoever sends the PR is responsible for maintaining an adapter not written by the JES author
- Issues/PRs asking to add your WM to wm_repo are also accepted, and this option is **recommended**
- When the connection API changes, the author will notify all WM authors in issues about the change of the connection API, if the WM is listed in wm_repo or it is a core adapter not by the JES author; the issue will include an explanation of the update + a new template

- The stub is made for typical WMs with workspaces or coordinates; if your WM has a different system, tell the author in an [Issue](https://github.com/ORFLEM/just_enough_shell/issues/new), and the author will write a 3rd `custom` mode that outputs text, i.e. ready-made text
