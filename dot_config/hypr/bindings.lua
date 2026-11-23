-- Keep only your personal keybinding overrides here. Add new bindings or
-- unbind defaults before replacing them.

-- See current bindings and descriptions:
--   omarchy menu keybindings --print

-- To disable every Omarchy default binding, set this in
-- ~/.config/hypr/hyprland.lua before require("default.hypr.omarchy"), then add
-- only the bindings you want below:
--   omarchy_default_bindings = false

-- To disable all preinstalled app/webapp bindings, set:
--   omarchy_preinstalled_bindings = false

-- Add a new binding.
-- o.bind("SUPER + SHIFT + R", "SSH", "alacritty -e ssh your-server")

-- Change an existing binding by unbinding it first, then binding the key again.
-- This example changes SUPER+SPACE from the launcher to the Omarchy root menu.
-- hl.unbind("SUPER + SPACE")
-- o.bind("SUPER + SPACE", "Omarchy menu", "omarchy-menu toggle root")

-- Disable a default binding without replacing it.
-- hl.unbind("SUPER + SHIFT + B")

-- Logitech MX Keys examples:
-- o.bind("SUPER + SHIFT + S", nil, "omarchy-capture-screenshot")
-- o.bind("SUPER + H", nil, "voxtype record toggle")
-- o.bind("SUPER + PERIOD", nil, "omarchy-shell shell toggle omarchy.emojis")


-- OBS save replay buffer clip
o.bind("SUPER + F1", "OBS - Save replay buffer", "obs-cmd --websocket obsws://127.0.0.1:4455/RCKr8DFkp35pDwK1 replay save")

-- Vim-style focus: free up SUPER + H/J/K/L
hl.unbind("SUPER + H")
hl.unbind("SUPER + J")
hl.unbind("SUPER + K")
hl.unbind("SUPER + L")
o.bind("SUPER + H", "Focus left",  hl.dsp.focus({ direction = "l" }))
o.bind("SUPER + J", "Focus down",  hl.dsp.focus({ direction = "d" }))
o.bind("SUPER + K", "Focus up",    hl.dsp.focus({ direction = "u" }))
o.bind("SUPER + L", "Focus right", hl.dsp.focus({ direction = "r" }))

-- Re-homed defaults
hl.unbind("SUPER + SLASH")
hl.unbind("SUPER + BACKSLASH")
hl.unbind("SUPER + SEMICOLON")
o.bind("SUPER + SLASH",     "Keybindings",           "omarchy menu keybindings")
o.bind("SUPER + BACKSLASH", "Toggle window split",   hl.dsp.layout("togglesplit"))
o.bind("SUPER + SEMICOLON", "Cycle workspace layout","omarchy-hyprland-workspace-layout-toggle")

-- Vim-style swap
o.bind("SUPER + SHIFT + H", "Swap window left",  hl.dsp.window.swap({ direction = "l" }))
o.bind("SUPER + SHIFT + J", "Swap window down",  hl.dsp.window.swap({ direction = "d" }))
o.bind("SUPER + SHIFT + K", "Swap window up",    hl.dsp.window.swap({ direction = "u" }))
o.bind("SUPER + SHIFT + L", "Swap window right", hl.dsp.window.swap({ direction = "r" }))

