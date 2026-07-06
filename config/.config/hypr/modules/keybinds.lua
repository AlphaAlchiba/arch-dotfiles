local mainMod = "SUPER"

-- Example binds, see https://wiki.hypr.land/Configuring/Basics/Binds/ for more
hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd(browser))
local closeWindowBind = hl.bind(mainMod .. " + C", hl.dsp.window.close())
-- closeWindowBind:set_enabled(false)
-- hl.bind(mainMod .. " + M", hl.dsp.exec_cmd("command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'"))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))
-- hl.bind(mainMod .. " + Z", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + X", function()
	hl.dsp.window.float({ action = "toggle" })
end)
hl.bind(mainMod .. " + R", hl.dsp.exec_cmd(menu))
-- hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen({ action = "toggle" }))
-- Move focus with mainMod + vim keys
hl.bind(mainMod .. " + H", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + L", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + K", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + J", hl.dsp.focus({ direction = "down" }))
-- move window in the workspaces with vim keys
hl.bind(mainMod .. " + SHIFT + L", hl.dsp.window.move({ direction = "right" }))
hl.bind(mainMod .. " + SHIFT + H", hl.dsp.window.move({ direction = "left" }))
hl.bind(mainMod .. " + SHIFT + K", hl.dsp.window.move({ direction = "up" }))
hl.bind(mainMod .. " + SHIFT + J", hl.dsp.window.move({ direction = "down" }))
-- screenshots
hl.bind(mainMod .. " + S", hl.dsp.exec_cmd("hyprshot -m region --raw | satty --filename -"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.exec_cmd("hyprshot -m window --raw | satty --filename -"))
hl.window_rule({ match = { class = "com.gabm.satty" }, float = true })
-- color picker
hl.bind(mainMod .. " + P", hl.dsp.exec_cmd("hyprpicker --notify --autocopy --format hex"))

-- Switch workspaces with mainMod + [0-9]
-- Move active window to a workspace with mainMod + SHIFT + [0-9]
for i = 1, 10 do
	local key = i % 10
	hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }))
	hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
	hl.bind(mainMod .. " + ALT + " .. key, hl.dsp.window.move({ workspace = i, follow = false }))
end

-- resize windows
local resizeStep = 50

hl.bind("SUPER + ALT + L", hl.dsp.window.resize({ x = resizeStep, y = 0, relative = true }))
hl.bind("SUPER + ALT + H", hl.dsp.window.resize({ x = -resizeStep, y = 0, relative = true }))
hl.bind("SUPER + ALT + J", hl.dsp.window.resize({ x = 0, y = resizeStep, relative = true }))
hl.bind("SUPER + ALT + K", hl.dsp.window.resize({ x = 0, y = -resizeStep, relative = true }))

-- change horizontal vs vertical tiling (togglesplit)
hl.bind(mainMod .. " + ALT + O", hl.dsp.layout("togglesplit"))

-- spotify special workspace
hl.bind(mainMod .. " + M", hl.dsp.workspace.toggle_special("spotify"))
hl.workspace_rule({ workspace = "special:spotify", on_created_empty = "spotify" })
hl.window_rule({
	match = { class = "Spotify" },
	float = true,
	center = true,
	size = { "(monitor_w*0.9)", "(monitor_h*0.9)" },
})

-- obsidian special workspace
hl.bind(mainMod .. " + O", hl.dsp.workspace.toggle_special("obsidian"))
hl.workspace_rule({ workspace = "special:obsidian", on_created_empty = "obsidian" })
hl.window_rule({
	match = { class = "obsidian" },
	float = true,
	center = true,
	size = { "(monitor_w*0.9)", "(monitor_h*0.9)" },
})

-- hl.layer_rule({ match = { namespace = "quickshell" }, blur = true })

-- signal special workspace
hl.bind(mainMod .. " + I", hl.dsp.workspace.toggle_special("signal"))
hl.workspace_rule({ workspace = "special:signal", on_created_empty = "signal-desktop" })
hl.window_rule({ match = { class = "signal" }, float = true, size = { "(monitor_w*0.6)", "(monitor_h*0.6)" } })

-- Scroll through existing workspaces with mainMod + scroll
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

-- Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Laptop multimedia keys for volume and LCD brightness
hl.bind(
	"XF86AudioRaiseVolume",
	hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioLowerVolume",
	hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioMute",
	hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioMicMute",
	hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),
	{ locked = true, repeating = true }
)
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"), { locked = true, repeating = true })
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })

-- Window rules
local suppressMaximizeRule = hl.window_rule({
	name = "suppress-maximize-events",
	match = { class = ".*" },
	suppress_event = "maximize",
})
-- suppressMaximizeRule:set_enabled(false)

hl.window_rule({
	name = "fix-xwayland-drags",
	match = {
		class = "^$",
		title = "^$",
		xwayland = true,
		float = true,
		fullscreen = false,
		pin = false,
	},
	no_focus = true,
})

hl.window_rule({
	name = "move-hyprland-run",
	match = { class = "hyprland-run" },
	move = "20 monitor_h-120",
	float = true,
})
