-- See https://wiki.hypr.land/Configuring/Basics/Monitors/

-- Machine-specific monitor rules must be registered before the catch-all:
-- Hyprland applies the first matching monitor rule, so the wildcard below
-- has to come last. Copy monitors_local.lua.example to monitors_local.lua
-- (untracked) to configure this machine.
if package and package.loaded then
	package.loaded["modules.monitors_local"] = nil
end
local ok, err = pcall(require, "modules.monitors_local")
if not ok and not tostring(err):find("not found", 1, true) then
	print("[hypr] monitors_local.lua: " .. tostring(err))
end

hl.monitor({
	output = "",
	mode = "preferred",
	position = "auto",
	scale = 1,
	disabled = false,
})
