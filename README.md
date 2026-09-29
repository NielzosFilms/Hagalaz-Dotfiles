Hagalaz — Omarchy theme context

A dark fantasy / evil-castle theme for Omarchy 4 (Arch Linux, Hyprland). Named after the rune ᚺ. This document is meant to be pasted in as context for future work on the theme.

System
Distro: Omarchy (Arch Linux + Hyprland)
Omarchy generation: 4 (the new Quickshell-based shell, not Waybar)
File manager: Yazi (terminal-based, replacing Dolphin)
Theme folder: ~/.config/omarchy/themes/hagalaz/
Vibe

Evil, evil castle/cathedral, dark fantasy. An earlier variant of this theme was cooler and more goth-cyberpunk (codename "Nocturne" — violet/magenta/cyan); Hagalaz split off into the warmer, firelit direction: ash-black, bone, iron, and blood red. Torches flicker, embers drift, crows circle a black eclipse over a castle-cathedral.

Current palette (blood red variant)

The terminal colors were deliberately desaturated toward monochrome; red is the only color that keeps full punch.

Role	Hex	Notes
Background (ash black)	
#0a0807	Base background
Darker background	
#040302	
Dark background	
#070605	
Lighter background (soot)	
#14100e	Bars, notifications
Selection / iron	
#2e2724	Borders, selection, frames
Muted	
#6b635c	Comments, placeholders — same as color8
Foreground (bone)	
#d5cbbb	Body text
Dark foreground	
#867d73	
Light foreground	
#e3dacb	
Bright foreground	
#efe8dc	
Accent (blood red)	
#c1121f	Primary accent, active border start
Accent tail (dried blood)	
#5a0d10	Active border gradient end

Active window border gradient: rgba(c1121fff) rgba(5a0d10ff) 45deg Inactive window border: rgba(2e2724ff)

Terminal colors (color0–color15), near-monochrome except red
toml
color0  = "#0a0807"
color1  = "#b8323a"   # muted blood red — urgent notifications too
color2  = "#7d8a68"   # sage
color3  = "#a8956a"   # dusty gold
color4  = "#6f7f8c"   # grey-blue
color5  = "#8c6a76"   # dusty mauve
color6  = "#6f8c88"   # muted teal
color7  = "#c4bcae"
color8  = "#6b635c"   # = muted
color9  = "#d4474d"
color10 = "#9aa886"
color11 = "#c9b98a"
color12 = "#8fa0ae"
color13 = "#ad8b97"
color14 = "#8fadaa"
color15 = "#efe8dc"
Alternate accent tried: Wraith (not adopted as the main theme)

Cold spectral blue-grey, built as a separate hagalaz-wraith theme copy so it could be compared side by side with blood red.

Accent: 
#7fa0b5
Accent tail: 
#3c5566
Icon theme: Yaru-blue (vs. Yaru-red for the main theme)
color1 (red) was kept as-is even in this variant, so errors/urgent states still read as blood.

Other accent options explored in the HTML preview stage (for reference, not built out as full themes): Hellfire (
#e2591a/
#b3161b, the original ember pairing before blood red replaced it as the main accent), Bloodmoon (
#c1121f/
#5a0d10, this is what became the adopted blood-red palette), Plague (
#9fc04a/
#3f5a1c).

Structural / look-and-feel decisions
Rounding: 0 (sharp corners throughout)
Border size: 3px (thick iron frame, not thin)
Gaps: gaps_in = 6, gaps_out = 12
Blur: on, but light — size = 3, passes = 2, brightness = 0.7
Dim inactive windows: on, dim_strength = 0.18
Shadow: range = 24, render_power = 2, color = accent at ~40% alpha (blood red: rgba(c1121f66) / Hyprland-Lua 0x66c1121f)
Border animation: borderangle loop, linear bezier, speed 30 — rotates the active gradient continuously as a stand-in for a flickering torch (Hyprland has no native flicker effect)
Bar position: bottom (was the original design choice; also tested top)
Bar background: solid, not transparent
File-by-file inventory

Everything below was authored over the course of this conversation. Locations assume Omarchy 4 unless marked otherwise.

Theme core
File	Destination	Purpose
colors.toml	~/.config/omarchy/themes/hagalaz/colors.toml	The palette above. Omarchy 4 generates terminal/btop/Neovim/shell configs from this, including the two hyprland_active_border / hyprland_inactive_border keys.
icons.theme	~/.config/omarchy/themes/hagalaz/icons.theme	Contains Yaru-red; color-matches the file manager's icon set.
background image	~/.config/omarchy/themes/hagalaz/backgrounds/	User already had a suitable background before file generation started (castle/cathedral, dark, eclipse-style — matches an SVG mock-up built earlier of a castle-cathedral under a black sun, with crows, embers, and fog).
Omarchy 3.x-only files (kept for reference; not used since the user is on Omarchy 4)
File	Destination	Purpose
hyprland.conf	~/.config/omarchy/themes/hagalaz/hyprland.conf	Sets the active/inactive border colors via Hyprlang, for versions where colors.toml doesn't drive Hyprland directly.
frame-omarchy3.conf	appended to ~/.config/hypr/looknfeel.conf	The structural settings above (gaps, border size, rounding, blur, shadow, dim_inactive, borderangle) in Hyprlang syntax.
Omarchy 4 files (active)
File	Destination	Purpose
frame-omarchy4.lua	appended to ~/.config/hypr/looknfeel.lua (or wherever Hypr Lua overrides live)	Same structural settings as above, in Hyprland's Lua config format (hl.config({...}), hl.curve, hl.animation). Shadow color is an ARGB integer (0x66c1121f) rather than an rgba() string.
Yazi (terminal file manager) theme
File	Destination	Purpose
theme.toml	~/.config/yazi/theme.toml	Static, rendered Yazi theme using the blood-red palette. Colors folders grey-blue, images teal, audio/video mauve, archives gold, broken symlinks red; blood-red highlights on the active row, tabs, mode indicator, and all popup borders. Written against Yazi 26.x's [mgr]/[tabs]/[mode]/[status]/etc. schema.
yazi-theme.toml.tpl	~/.config/omarchy/themed/	Same theme as an Omarchy template ({{ accent }}, {{ color3 }}, etc.) so it regenerates automatically on omarchy-theme-set, instead of needing manual edits when the palette changes. Requires symlinking Yazi's theme.toml to Omarchy's generated per-theme output — exact current-theme path differs by Omarchy version, wasn't confirmed on the user's machine.
Top bar (Omarchy 4 shell, Quickshell/QML)

The user is on Omarchy 4, which uses its own Quickshell-based shell (not Waybar). Bar contents live in ~/.config/omarchy/shell.json under the bar key; once customized, that file is the sole source (no merge with defaults).

File	Destination	Purpose
hagalaz-bar.json	consumed by apply-bar.sh, merged into ~/.config/omarchy/shell.json's bar key	Bar layout: left = menu/skull button + workspaces; center = media + clock (ddd d MMM  HH:mm format); right = CPU, memory, update, indicators, tray, network, bluetooth, audio, power.
hagalaz-cpu	~/.config/omarchy/bar/scripts/hagalaz-cpu	Shell script polling /proc/stat over 0.5s to print cpu NN%. Tested and working in isolation.
hagalaz-mem	~/.config/omarchy/bar/scripts/hagalaz-mem	Shell script using free to print mem NN% (used - available). Tested and working in isolation.
apply-bar.sh	run manually	Backs up shell.json (once, kept across re-runs), installs the two scripts, merges the hagalaz-bar.json layout into bar, reloads the shell via omarchy-shell shell reloadConfig. Dry-run tested against a mocked omarchy-shell/jq.
Rune workspace widget

A custom plugin, local.rune-workspaces, replaces the built-in omarchy.workspaces in the bar. It relabels the ten workspace slots with the first ten Elder Futhark runes (ᚠᚢᚦᚨᚱᚲᚷᚹᚺᚾ — workspace 9 = ᚺ = Hagalaz itself) and underlines the focused one in blood red, keeping the same focus/click logic as the built-in widget.

Files: rune-BarWidget.qml and rune-manifest.json go in ~/.config/omarchy/plugins/local.rune-workspaces/; install-plugin.sh installs, validates, enables, and wires it into the bar layout in place of omarchy.workspaces.

Status: unconfirmed — not yet verified rendering on screen. If picking this back up, next steps are checking omarchy plugin validate output and the shell logs (qs log -p "$OMARCHY_PATH/shell" --tail 100), and confirming whether WidgetButton supports a text-color property (source not yet seen).

Design reference (from the HTML mock-ups)

Two full HTML/CSS/SVG preview pages were built earlier as mood boards before any real Omarchy files were written. They are not part of the theme's installed files, but capture the intended visual target:

Nocturne — the initial cooler goth-cyberpunk direction (violet/magenta/cyan on near-black), later abandoned in favor of the warmer direction below.
Dreadspire — the dark-fantasy/evil-castle direction that Hagalaz is directly descended from. Established: firelit ember/hellfire palette (later swapped for blood red as the adopted accent), thick iron window frames with gold corner marks, dimmed inactive windows, a torch-flicker animation, bottom bar with rune workspace glyphs, an SVG wallpaper of a castle-cathedral under a black eclipse with crows/embers/fog/lightning, and an organ-pipe-style audio visualizer mock. Interactive controls in that page let the user compare "Hellfire / Bloodmoon / Plague / Wraith" accent pairings, bar top/bottom placement, border thickness, glow amount, and torch flicker on/off — Bloodmoon (blood red) is what got carried into the real theme.
Naming

The theme was originally unnamed/described only by vibe, briefly went by the working title "Dreadspire" during the HTML mock-up stage, and was then formally named Hagalaz (ᚺ, an Elder Futhark rune) by the user's explicit instruction, which is also why workspace 9 in the rune widget is significant.

