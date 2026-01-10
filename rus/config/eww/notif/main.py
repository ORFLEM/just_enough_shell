import dbus
import dbus.service
from dbus.mainloop.glib import DBusGMainLoop
from gi.repository import GLib
import threading
import time
import subprocess
import os

class Notification:
    def __init__(self, notif_id, summary, body, icon, actions, app_name):
        self.id = notif_id
        self.summary = summary
        self.body = body
        self.icon = icon
        self.actions = actions
        self.app_name = app_name

notifications = []
notification_id_counter = 1

SOUND_FILE = os.path.expanduser("~/.config/eww/notif/mes.mp3")

def play_sound():
    try:
        subprocess.Popen(['pw-play', SOUND_FILE], 
                        stdout=subprocess.DEVNULL, 
                        stderr=subprocess.DEVNULL)
    except:
        pass

def remove_object(notif):
    time.sleep(10)
    if notif in notifications:
        notifications.remove(notif)
        print_state()

def add_object(notif):
    notifications.insert(0, notif)
    print_state()
    play_sound()
    timer_thread = threading.Thread(target=remove_object, args=(notif,), daemon=True)
    timer_thread.start()

def print_state():
    string = ""
    for item in notifications:
        summary = (item.summary or '').replace("'", "").replace('"', '').replace('\n', ' ')
        body = (item.body or '').replace("'", "").replace('"', '').replace('\n', ' ')
        icon = item.icon or ''
        
        # Используем dbus-send для вызова методов
        close_cmd = f"dbus-send --session --type=method_call --dest=org.freedesktop.Notifications /org/freedesktop/Notifications org.freedesktop.Notifications.CloseNotification uint32:{item.id}"
        action_cmd = f"dbus-send --session --type=method_call --dest=org.freedesktop.Notifications /org/freedesktop/Notifications org.freedesktop.Notifications.InvokeAction uint32:{item.id}"
        
        string += f"""
            (eventbox 
                :onclick "{action_cmd}"
                :onrightclick "{close_cmd}"
                (button :class 'notif'
                    (box :orientation 'horizontal' :space-evenly false
                        (image :image-width 80 :image-height 80 :path '{icon}')
                        (box :orientation 'vertical'
                            (label :limit-width 250 :wrap true :text '{summary}')
                            (label :limit-width 250 :wrap true :text '{body}')
                        )
                    )
                )
            )
        """
    
    string = string.replace('\n', ' ')
    print(f"(box :orientation 'vertical' {string or ''})", flush=True)

class NotificationServer(dbus.service.Object):
    def __init__(self):
        bus_name = dbus.service.BusName('org.freedesktop.Notifications', 
                                       bus=dbus.SessionBus())
        dbus.service.Object.__init__(self, bus_name, '/org/freedesktop/Notifications')
        self.bus = dbus.SessionBus()

    @dbus.service.method('org.freedesktop.Notifications', 
                        in_signature='susssasa{ss}i', 
                        out_signature='u')
    def Notify(self, app_name, replaces_id, app_icon, summary, body, actions, hints, timeout):
        global notification_id_counter
        
        notif_id = notification_id_counter
        notification_id_counter += 1
        
        notif = Notification(notif_id, summary, body, app_icon, actions, app_name)
        add_object(notif)
        
        return notif_id

    @dbus.service.method('org.freedesktop.Notifications', 
                        in_signature='u', 
                        out_signature='')
    def CloseNotification(self, notif_id):
        """Закрыть уведомление по ID"""
        global notifications
        notifications = [n for n in notifications if n.id != notif_id]
        print_state()
        self.NotificationClosed(notif_id, 2)

    @dbus.service.method('org.freedesktop.Notifications', 
                        in_signature='u', 
                        out_signature='')
    def InvokeAction(self, notif_id):
        """Выполнить действие и закрыть"""
        global notifications
        notif = next((n for n in notifications if n.id == notif_id), None)
        
        if notif:
            # Если есть actions, отправляем сигнал
            if notif.actions and len(notif.actions) >= 2:
                action_key = notif.actions[0]
                self.ActionInvoked(notif_id, action_key)
            
            # Удаляем уведомление
            notifications = [n for n in notifications if n.id != notif_id]
            print_state()
            self.NotificationClosed(notif_id, 2)

    @dbus.service.signal('org.freedesktop.Notifications', signature='us')
    def ActionInvoked(self, notif_id, action_key):
        pass

    @dbus.service.signal('org.freedesktop.Notifications', signature='uu')
    def NotificationClosed(self, notif_id, reason):
        pass

    @dbus.service.method('org.freedesktop.Notifications', 
                        out_signature='ssss')
    def GetServerInformation(self):
        return ("Custom Notification Server", "ExampleNS", "1.0", "1.2")

    @dbus.service.method('org.freedesktop.Notifications', 
                        out_signature='as')
    def GetCapabilities(self):
        return ["actions", "body"]

DBusGMainLoop(set_as_default=True)

if __name__ == '__main__':
    server = NotificationServer()
    mainloop = GLib.MainLoop()
    mainloop.run()
