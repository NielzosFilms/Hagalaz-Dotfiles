-- Change the default Omarchy look'n'feel.

-- https://wiki.hypr.land/Configuring/Basics/Variables/#general
-- hl.config({
--   general = {
--     -- No gaps between windows or borders.
--     gaps_in = 0,
--     gaps_out = 0,
--     border_size = 0,
--
--     -- Change to niri-like side-scrolling layout.
--     layout = "scrolling",
--   },
-- })

-- https://wiki.hypr.land/Configuring/Basics/Variables/#decoration
-- hl.config({
--   decoration = {
--     -- Use round window corners.
--     rounding = 8,
--
--     -- Dim unfocused windows (0.0 = no dim, 1.0 = fully dimmed).
--     dim_inactive = true,
--     dim_strength = 0.15,
--   },
-- })

-- https://wiki.hypr.land/Configuring/Basics/Variables/#animations
-- hl.config({
--   animations = {
--     -- Disable all animations.
--     enabled = false,
--   },
-- })

-- https://wiki.hypr.land/Configuring/Basics/Variables/#layout
-- hl.config({
--   layout = {
--     -- Avoid overly wide single-window layouts on wide screens.
--     single_window_aspect_ratio = { 1, 1 },
--   },
-- })

-- https://wiki.hypr.land/Configuring/Layouts/Scrolling-Layout/
-- hl.config({
--   scrolling = {
--     -- See only one column per screen instead of two.
--     column_width = 0.97,
--   },
-- })


-- Hagalaz frame settings (Omarchy 4, Hyprland Lua config)
-- Append to your Hypr look-and-feel Lua file in ~/.config/hypr/
-- Border colors come from colors.toml, these are the structural settings.

hl.config({
    general = {
        gaps_in = 6,
        gaps_out = 12,
        border_size = 3,
    },
    decoration = {
        rounding = 0,
        dim_inactive = false,
        dim_strength = 0.18,
        blur = {
            enabled = true,
            size = 8,
            passes = 1,
            brightness = 0.3,
            ignore_opacity = true,
        },
        shadow = {
            enabled = false,
            range = 6,
            render_power = 1,
            color = "#c1121f66", -- ARGB integer, ember at 40% alpha
        },
    },
})

-- slowly rotates the gradient border, the closest thing to a flickering torch
hl.curve("linear", { type = "bezier", points = { {0, 0}, {1, 1} } })
hl.animation({ leaf = "borderangle", enabled = true, speed = 30, bezier = "linear", style = "loop" })
