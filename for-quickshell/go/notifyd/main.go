// jes-notifyd.go
package main

import (
	"encoding/json"
	"log"
	"os"
	"path/filepath"
	"strings"
	"sync"
	"time"

	"github.com/godbus/dbus/v5"
	"github.com/godbus/dbus/v5/introspect"
)

const (
	busName = "org.freedesktop.Notifications"
	objPath = "/org/freedesktop/Notifications"
	iface   = "org.freedesktop.Notifications"
	logPath = "/tmp/jes-notification.jsonl"

)

type Action struct {
	Label  string `json:"label"`
	Action string `json:"action"`
}

type Item struct {
	ID               uint32   `json:"id"`
	AppName          string   `json:"appName"`
	Summary          string   `json:"summary"`
	Body             string   `json:"body"`
	Image            string   `json:"image"`
	Actions          []Action `json:"actions"`
	ExpireTimeout    int      `json:"expireTimeout"`
	HasDefaultAction bool     `json:"hasDefaultAction"`
	Timestamp        int64    `json:"timestamp"`
}

type notif struct {
	Item
	timer *time.Timer
}

type Event struct {
	Op    string  `json:"op"`              // snapshot | add | remove | clear
	Item  *Item   `json:"item,omitempty"`
	ID    uint32  `json:"id,omitempty"`
	Items []*Item `json:"items,omitempty"`
}

type daemon struct {
	conn   *dbus.Conn
	mu     sync.Mutex
	store  map[uint32]*notif
	nextID uint32
	file   *os.File
}

// --- JSONL-журнал ---

func (d *daemon) emitEvent(e Event) {
	data, err := json.Marshal(e)
	if err != nil {
		return
	}
	data = append(data, '\n')
	if _, err := d.file.Write(data); err != nil {
		log.Println("write event:", err)
	}
}

func (d *daemon) snapshotLocked() {
	items := make([]*Item, 0, len(d.store))
	for _, n := range d.store {
		items = append(items, &n.Item)
	}
	d.emitEvent(Event{Op: "snapshot", Items: items})
}

// --- D-Bus методы ---

func (d *daemon) Notify(appName string, replacesID uint32, appIcon, summary, body string,
	actions []string, hints map[string]dbus.Variant, expireTimeout int32) (uint32, *dbus.Error) {

	d.mu.Lock()
	defer d.mu.Unlock()

	var actList []Action
	hasDefault := false
	for i := 0; i+1 < len(actions); i += 2 {
		actList = append(actList, Action{Label: actions[i+1], Action: actions[i]})
		if actions[i] == "default" {
			hasDefault = true
		}
	}

	image := appIcon
	if p, ok := hints["image-path"]; ok {
		if s, ok := p.Value().(string); ok && s != "" {
			image = s
		}
	}
	if strings.HasPrefix(image, "~/") {
		if home, err := os.UserHomeDir(); err == nil {
			image = filepath.Join(home, image[2:])
		}
	}

	var id uint32
	if replacesID != 0 {
		if existing, ok := d.store[replacesID]; ok {
			if existing.timer != nil {
				existing.timer.Stop()
			}
			id = replacesID
		} else {
			id = d.nextID
			d.nextID++
		}
	} else {
		id = d.nextID
		d.nextID++
	}

	n := &notif{Item: Item{
		ID:               id,
		AppName:          appName,
		Summary:          summary,
		Body:             body,
		Image:            image,
		Actions:          actList,
		ExpireTimeout:    int(expireTimeout),
		HasDefaultAction: hasDefault,
		Timestamp:        time.Now().UnixMilli(),
	}}
	d.store[id] = n
	d.emitEvent(Event{Op: "add", Item: &n.Item})
	return id, nil
}

func (d *daemon) CloseNotification(id uint32) *dbus.Error {
	d.mu.Lock()
	defer d.mu.Unlock()
	n, ok := d.store[id]
	if !ok {
		return nil
	}
	if n.timer != nil {
		n.timer.Stop()
	}
	delete(d.store, id)
	d.emitEvent(Event{Op: "remove", ID: id})
	d.conn.Emit(objPath, iface+".NotificationClosed", id, uint32(3))
	return nil
}

func (d *daemon) InvokeAction(id uint32, action string) *dbus.Error {
	d.mu.Lock()
	defer d.mu.Unlock()
	n, ok := d.store[id]
	if !ok {
		return nil
	}
	if n.timer != nil {
		n.timer.Stop()
	}
	d.conn.Emit(objPath, iface+".ActionInvoked", id, action)
	delete(d.store, id)
	d.emitEvent(Event{Op: "remove", ID: id})
	d.conn.Emit(objPath, iface+".NotificationClosed", id, uint32(2))
	return nil
}

func (d *daemon) PauseExpiry(id uint32) *dbus.Error {
	d.mu.Lock()
	defer d.mu.Unlock()
	if n, ok := d.store[id]; ok && n.timer != nil {
		n.timer.Stop()
	}
	return nil
}

func (d *daemon) ResumeExpiry(id uint32) *dbus.Error {
	return nil
}

func (d *daemon) ClearAll() *dbus.Error {
	d.mu.Lock()
	defer d.mu.Unlock()
	ids := make([]uint32, 0, len(d.store))
	for id := range d.store {
		ids = append(ids, id)
	}
	for _, id := range ids {
		if n := d.store[id]; n.timer != nil {
			n.timer.Stop()
		}
		delete(d.store, id)
		d.emitEvent(Event{Op: "remove", ID: id})
		d.conn.Emit(objPath, iface+".NotificationClosed", id, uint32(3))
	}
	return nil
}

func (d *daemon) GetCapabilities() ([]string, *dbus.Error) {
	return []string{"body", "body-markup", "actions", "icon-static"}, nil
}

func (d *daemon) GetServerInformation() (string, string, string, string, *dbus.Error) {
	return "JES", "JES", "1.0", "1.2", nil
}

// --- Инициализация ---

func main() {
	conn, err := dbus.ConnectSessionBus()
	if err != nil {
		log.Fatal(err)
	}
	defer conn.Close()

	// Truncate при старте — QML переиграет журнал с чистого листа.
	f, err := os.Create(logPath)
	if err != nil {
		log.Fatal(err)
	}

	d := &daemon{
		conn:   conn,
		store:  make(map[uint32]*notif),
		nextID: 1,
		file:   f,
	}

	if err := conn.Export(d, objPath, iface); err != nil {
		log.Fatal(err)
	}

	node := &introspect.Node{
		Name: objPath,
		Interfaces: []introspect.Interface{
			introspect.IntrospectData,
			{
				Name: iface,
				Methods: []introspect.Method{
					{Name: "Notify", Args: []introspect.Arg{
						{Name: "app_name", Type: "s", Direction: "in"},
						{Name: "replaces_id", Type: "u", Direction: "in"},
						{Name: "app_icon", Type: "s", Direction: "in"},
						{Name: "summary", Type: "s", Direction: "in"},
						{Name: "body", Type: "s", Direction: "in"},
						{Name: "actions", Type: "as", Direction: "in"},
						{Name: "hints", Type: "a{sv}", Direction: "in"},
						{Name: "expire_timeout", Type: "i", Direction: "in"},
						{Name: "id", Type: "u", Direction: "out"},
					}},
					{Name: "CloseNotification", Args: []introspect.Arg{
						{Name: "id", Type: "u", Direction: "in"},
					}},
					{Name: "InvokeAction", Args: []introspect.Arg{
						{Name: "id", Type: "u", Direction: "in"},
						{Name: "action", Type: "s", Direction: "in"},
					}},
					{Name: "PauseExpiry", Args: []introspect.Arg{
						{Name: "id", Type: "u", Direction: "in"},
					}},
					{Name: "ResumeExpiry", Args: []introspect.Arg{
						{Name: "id", Type: "u", Direction: "in"},
					}},
					{Name: "ClearAll"},
					{Name: "GetCapabilities", Args: []introspect.Arg{
						{Name: "caps", Type: "as", Direction: "out"},
					}},
					{Name: "GetServerInformation", Args: []introspect.Arg{
						{Name: "name", Type: "s", Direction: "out"},
						{Name: "vendor", Type: "s", Direction: "out"},
						{Name: "version", Type: "s", Direction: "out"},
						{Name: "spec_version", Type: "s", Direction: "out"},
					}},
				},
				Signals: []introspect.Signal{
					{Name: "NotificationClosed", Args: []introspect.Arg{
						{Name: "id", Type: "u"}, {Name: "reason", Type: "u"},
					}},
					{Name: "ActionInvoked", Args: []introspect.Arg{
						{Name: "id", Type: "u"}, {Name: "action_key", Type: "s"},
					}},
				},
			},
		},
	}
	if err := conn.Export(introspect.NewIntrospectable(node), objPath, "org.freedesktop.DBus.Introspectable"); err != nil {
		log.Fatal(err)
	}

	reply, err := conn.RequestName(busName, dbus.NameFlagDoNotQueue)
	if err != nil || reply != dbus.RequestNameReplyPrimaryOwner {
		log.Fatalf("RequestName %s failed: %v (reply=%v)", busName, err, reply)
	}

	d.mu.Lock()
	d.snapshotLocked()
	d.mu.Unlock()

	log.Println("JES notification daemon started; journal:", logPath)
	select {}
}
