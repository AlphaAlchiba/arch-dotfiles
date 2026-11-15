-- Float media windows instead of tiling them.
-- Classes are checked with `hyprctl clients`; adjust if an app changes its
-- Wayland app_id.
--
-- `size` only accepts numbers/expressions (no percentages). mpv uses
-- `autofit=60%x60%` from config/mpv/mpv.conf, so it is left to choose its own
-- size while Hyprland floats and centers it.

hl.window_rule({
	name = "float-mpv",
	match = { class = "^(mpv)$" },
	float = true,
	center = true,
})

hl.window_rule({
	name = "float-loupe",
	match = { class = "^(org.gnome.Loupe)$" },
	float = true,
	size = { "monitor_w * 0.7", "monitor_h * 0.7" },
	center = true,
})

hl.window_rule({
	name = "float-ark",
	match = { class = "^(org.kde.ark|ark)$" },
	float = true,
	size = "900 600",
	center = true,
})
