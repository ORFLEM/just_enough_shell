// main.zig
const wayland = @import("wayland");
const wl = wayland.client.wl;
const toplevel = wayland.client.wlr_foreign_toplevel_management_v1;

pub fn main() !void {
    // 1. Подключение к композитору
    var display = try wl.Display.connect(null);
    defer display.disconnect();

    // 2. Получение реестра глобальных объектов
    const registry = display.getRegistry();
    defer registry.destroy();

    // 3. Структура для хранения состояния
    const State = struct {
        manager: ?*toplevel.ZwlrForeignToplevelManagerV1 = null,
    };
    var state = State{};

    // 4. Обработчик событий реестра
    registry.setListener(*State, struct {
        fn global(_: *wl.Registry, event: wl.Registry.Global, state: *State) void {
            // Ищем нужный протокол по его имени
            if (std.mem.eql(u8, event.interface, toplevel.ZwlrForeignToplevelManagerV1.getInterface().name)) {
                // Биндим (связываем) интерфейс
                state.manager = event.bind(
                    toplevel.ZwlrForeignToplevelManagerV1,
                    toplevel.ZwlrForeignToplevelManagerV1.getInterface(),
                    event.version,
                ) catch unreachable;

                // Назначаем слушателя для менеджера тоplevel-ов
                state.manager.?.setListener(*State, struct {
                    pub fn toplevel(_: *toplevel.ZwlrForeignToplevelManagerV1, event: toplevel.ZwlrForeignToplevelManagerV1.Toplevel, state: *State) void {
                        const handle = event.toplevel;
                        handle.setListener(*State, struct {
                            pub fn title(_: *toplevel.ZwlrForeignToplevelHandleV1, event: toplevel.ZwlrForeignToplevelHandleV1.Title, _: *State) void {
                                std.debug.print("Active window title: {s}\n", .{event.title});
                            }
                            // Обработчики для finished, app_id и т.д.
                            pub fn appId(_: *toplevel.ZwlrForeignToplevelHandleV1, event: toplevel.ZwlrForeignToplevelHandleV1.AppId, _: *State) void {
                                std.debug.print("App ID: {s}\n", .{event.app_id});
                            }
                        }, state);
                    }
                }, state);
            }
        }
    }.global, &state);

    // 5. Запуск цикла обработки событий
    while (true) {
        _ = try display.dispatch();
    }
}
