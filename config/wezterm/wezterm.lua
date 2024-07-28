local wezterm = require("wezterm")

local config = {
	font = wezterm.font("MesloLGS Nerd Font Mono"),
	font_size = 14.0,
	color_scheme = "catppuccin-mocha",
	enable_tab_bar = false,
	window_padding = {
		left = 0,
		right = 0,
		top = 0,
		bottom = 0,
	},
}

return config
