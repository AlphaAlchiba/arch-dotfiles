# Hyprland configuration

## Files

| File | Tracked? | Purpose |
|---|---|---|
| `hyprland.lua` | yes | Entry point. Loads the modules and starts Brain_Shell. |
| `modules/monitors.lua` | yes | Generic monitor config: loads the local rules, then a catch-all. |
| `modules/monitors_local.lua` | **no** | Machine-specific monitor rules (serial-based `desc:` strings, disable flags, workspace pinning). Gitignored. |
| `modules/monitors_local.lua.example` | yes | Template for the local file. |
| `modules/appearance.lua` | yes | Gaps, borders, blur, shadows, layout. |
| `modules/keybinds.lua` | yes | Key bindings. |

## Monitors

The tracked `modules/monitors.lua` is deliberately generic:

```lua
pcall(require, "modules.monitors_local")   -- specific rules first

hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1, disabled = false })
```

**Order matters.** Hyprland applies the **first matching monitor rule**, so the
wildcard `output = ""` must come last. The local file is loaded before it, which
lets specific rules win. If the local file is absent the catch-all handles every
monitor.

### Finding a monitor's description

```bash
hyprctl monitors
```

Take the `description:` line and prefix it with `desc:`:

```text
description: Manufacturer Model SERIAL
→ desc:Manufacturer Model SERIAL
```

The serial is part of the description, which is why this file is not tracked.

### Creating the local file

```bash
cp ~/.config/hypr/modules/monitors_local.lua.example \
   ~/.config/hypr/modules/monitors_local.lua
```

Edit the `desc:Manufacturer Model SERIAL` placeholders. The file is gitignored;
never commit it.

### Common rules

Disable a monitor:

```lua
hl.monitor({
    output = "desc:Manufacturer Model SERIAL",
    mode = "2560x1440@120",
    position = "0x0",
    scale = 1,
    disabled = true,
})
```

Place and enable one:

```lua
hl.monitor({
    output = "desc:Manufacturer Model SERIAL",
    mode = "2560x1440@120",
    position = "0x0",
    scale = 1,
    disabled = false,
})
```

### Reload and verify

```bash
hyprctl reload
hyprctl monitors          # check disabled / mode / position
hyprctl configerrors      # check for Lua/config errors
```

## Workspaces

Workspace-to-monitor rules live in the same local file:

```lua
hl.workspace_rule({ workspace = "1", monitor = "desc:Manufacturer Model SERIAL", default = true })
hl.workspace_rule({ workspace = "2", monitor = "desc:Manufacturer Model SERIAL" })
```

- `default = true` is the workspace shown when the monitor is first used.
- Workspaces without a rule go to the default monitor.
- If you disable a monitor, its workspace rules become inert; those workspaces
  fall back to the remaining monitor.

## Idle, lock, and suspend

`hypridle` is started from `hyprland.lua` with the tracked config
`hypridle.conf`. If `hypridle_local.conf` exists in this directory, it is used
instead.

| File | Tracked? | Purpose |
|---|---|---|
| `hypridle.conf` | yes | Default policy: dim, lock, DPMS off, suspend. |
| `hypridle_local.conf` | **no** | Optional machine-specific override (full config). Gitignored. |

Default policy:

| Timeout | Action |
|---|---|
| 5 min | dim the internal panel (`brightnessctl`) |
| 5.5 min | lock the session with `hyprlock` |
| 6 min | power the displays off (`hyprctl dispatch dpms off`) |
| 15 min | suspend (`systemctl suspend`) |

### Per-machine override

Some machines only expose `s2idle` (no S3), and resume can fail to restore a
USB4/Thunderbolt dock's DisplayPort tunnel or USB devices. To keep such a
machine awake while still locking and blanking the displays, create a local
override without the suspend listener:

```bash
cp ~/.config/hypr/hypridle.conf ~/.config/hypr/hypridle_local.conf
# edit hypridle_local.conf and remove the final suspend listener
pkill hypridle
hypridle -c ~/.config/hypr/hypridle_local.conf &
```

The local file is gitignored, so the shared default stays portable. Verify it
with `hypridle -c ~/.config/hypr/hypridle_local.conf -v`, which logs each
registered timeout.

To test suspend on a machine where it is disabled, use a recoverable test and
inspect the kernel log afterwards:

```bash
sudo rtcwake -m mem -s 30
journalctl -b -k | grep -Ei "DPIA|thunderbolt|usb"
```

If the displays blank but keyboard/mouse input does not bring them back, the
dock's USB hub may be losing power in standby; check the dock/monitor power
options and run `just dock-check`.

## Portability

`monitors_local.lua` is machine-specific and is not part of the repo. On a new
machine the generic catch-all applies until you recreate the file from the
example and fill in the local monitor descriptions.
