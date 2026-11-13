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

## Portability

`monitors_local.lua` is machine-specific and is not part of the repo. On a new
machine the generic catch-all applies until you recreate the file from the
example and fill in the local monitor descriptions.
