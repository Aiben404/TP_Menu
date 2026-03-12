# Snowman TP Menu — ESX Teleport Menu

A FiveM ESX teleport menu with a sleek dark theme.
Black background · Neon green accents · Bold typography · Smooth animations.

---

## 📁 File Structure

```
TP_Menu/
├── fxmanifest.lua
├── config.lua           ← All settings & locations here
├── client/
│   └── main.lua
├── server/
│   └── main.lua
└── html/
    ├── index.html
    ├── css/
    │   └── style.css
    └── js/
        └── app.js
```

---

## ⚙️ Installation

1. Drop the `TP_Menu` folder into your **resources** directory.
2. Add to your `server.cfg`:
   ```
   ensure TP_Menu
   ```
3. Make sure **es_extended** is started before this resource.
4. Configure `config.lua` to your needs (see below).
5. Restart your server.

---

## 🔧 Configuration (`config.lua`)

| Option | Default | Description |
|---|---|---|
| `Config.OpenKey` | `'F5'` | Key to toggle the menu |
| `Config.UseCommand` | `true` | Enable `/tpmenu` command |
| `Config.Command` | `'tpmenu'` | Command name |
| `Config.AdminGroup` | `'admin'` | ESX group for admin locations |
| `Config.VipGroup` | `'vip'` | ESX group for VIP locations |
| `Config.TeleportDelay` | `1500` | MS delay before TP executes |
| `Config.Notification` | `true` | Show chat notification |
| `Config.FreezeOnTP` | `true` | Freeze player during teleport |
| `Config.BlackScreenTP` | `true` | Black screen flash effect |
| `Config.LogTeleports` | `true` | Log TPs to server console |

---

## 📍 Adding Locations

In `config.lua`, add an entry to `Config.Locations`:

```lua
{
    id        = 21,                  -- Must be unique
    name      = 'My Location',
    cat       = 'city',             -- 'city' | 'jobs' | 'vip' | 'admin'
    tag       = 'free',             -- 'free' | 'job' | 'vip' | 'admin'
    dot       = 'green',            -- 'green' | 'blue' | 'orange' | 'purple' | 'red'
    label     = 'PUBLIC',           -- Badge text in UI
    x         = 100.0,
    y         = 200.0,
    z         = 30.0,
    heading   = 90.0,               -- Player facing direction after TP
    -- Optional filters:
    minJob    = 'police',           -- Only players with this job can see it
    adminOnly = true,               -- Only Config.AdminGroup can see it
    vipOnly   = true,               -- Only Config.VipGroup can see it
},
```

---

## 🎮 Controls

| Key | Action |
|---|---|
| `F5` (configurable) | Open / close menu |
| `/tpmenu` | Open / close menu |
| `↑ / ↓` | Navigate locations |
| `Enter` | Open confirm dialog |
| `Escape` | Close menu / dialog |
| Double-click | Open confirm dialog |

---

## 🔑 Permissions

- **Free locations** — visible to everyone
- **Job locations** (`minJob`) — only players with matching job
- **VIP locations** (`vipOnly = true`) — only players in `Config.VipGroup`
- **Admin locations** (`adminOnly = true`) — only players in `Config.AdminGroup`
- Admins automatically see all locations including VIP

---

## 📝 Notes

- To use a **different notify system** (e.g. ox_lib, mythic_notify), edit the `Notify()` function in `client/main.lua`.
- The menu is **NUI-based** — no ox_lib or menu framework required.
- Tested on **ESX Legacy**.

---

## 📸 Screenshots

![Screenshot 1](https://r2.fivemanage.com/fDUKi7rgEhC1caoH2Yksm/Screenshot2026-03-12113753.png)

![Screenshot 2](https://r2.fivemanage.com/fDUKi7rgEhC1caoH2Yksm/Screenshot2026-03-12113802.png)

![Screenshot 3](https://r2.fivemanage.com/fDUKi7rgEhC1caoH2Yksm/Screenshot2026-03-12113808.png)

![Screenshot 4](https://r2.fivemanage.com/fDUKi7rgEhC1caoH2Yksm/Screenshot2026-03-12113815.png)
