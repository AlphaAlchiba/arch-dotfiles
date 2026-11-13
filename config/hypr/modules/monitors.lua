-- See https://wiki.hypr.land/Configuring/Basics/Monitors/

hl.monitor({
	output = "",
	mode = "preferred",
	position = "auto",
	scale = 1,
	disabled = false,
})

-- Machine-specific monitor rules live in an untracked local file so the
-- public dotfiles do not expose device identifiers (e.g. monitor serials).
local local_rules = os.getenv("HOME") .. "/.config/hypr/modules/monitors.local.lua"
local f = io.open(local_rules, "r")
if f then
	f:close()
	dofile(local_rules)
end
