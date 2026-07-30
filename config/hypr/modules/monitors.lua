-- See https://wiki.hypr.land/Configuring/Basics/Monitors/

hl.monitor({
	output = "",
	mode = "preferred",
	position = "auto",
	scale = 1,
	disabled = false,
})

hl.monitor({
	output = "desc:External Monitor 1",
	mode = "2560x1440@120",
	position = "0x0",
	scale = 1,
	disabled = true,
})

hl.monitor({
	output = "desc:External Monitor 2",
	mode = "2560x1440@120",
	position = "2560x0",
	scale = 1,
	disabled = true,
})

hl.workspace_rule({ workspace = "1", monitor = "desc:External Monitor 1", default = true })
hl.workspace_rule({ workspace = "2", monitor = "desc:External Monitor 1" })
hl.workspace_rule({ workspace = "3", monitor = "desc:External Monitor 1" })
hl.workspace_rule({ workspace = "4", monitor = "desc:External Monitor 1" })
hl.workspace_rule({ workspace = "5", monitor = "desc:External Monitor 1" })
hl.workspace_rule({ workspace = "6", monitor = "desc:External Monitor 2", default = true })
hl.workspace_rule({ workspace = "7", monitor = "desc:External Monitor 2" })
hl.workspace_rule({ workspace = "8", monitor = "desc:External Monitor 2" })
hl.workspace_rule({ workspace = "9", monitor = "desc:External Monitor 2" })
hl.workspace_rule({ workspace = "0", monitor = "desc:External Monitor 2" })
