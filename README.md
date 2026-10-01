# Hagalaz — Omarchy theme context
 
A dark fantasy / evil-castle theme for Omarchy 4 (Arch Linux, Hyprland). Named after the rune ᚺ. This document is meant to be pasted in as context for future work on the theme.
 
## System
 
- **Distro:** Omarchy (Arch Linux + Hyprland)
- **Omarchy generation:** 4 (the new Quickshell-based shell, not Waybar)
- **File manager:** Yazi (terminal-based, replacing Dolphin)
- **Theme folder:** `~/.config/omarchy/themes/hagalaz/`
## Vibe
 
Evil, evil castle/cathedral, dark fantasy. An earlier variant of this theme was cooler and more goth-cyberpunk (codename "Nocturne" — violet/magenta/cyan); Hagalaz split off into the warmer, firelit direction: ash-black, bone, iron, and blood red. Torches flicker, embers drift, crows circle a black eclipse over a castle-cathedral.
 
## Current palette (blood red variant)
 
The terminal colors were deliberately desaturated toward monochrome; red is the only color that keeps full punch.
 
| Role | Hex | Notes |
|---|---|---|
| Background (ash black) | `#0a0807` | Base background |
| Darker background | `#040302` | |
| Dark background | `#070605` | |
| Lighter background (soot) | `#14100e` | Bars, notifications |
| Selection / iron | `#2e2724` | Borders, selection, frames |
| Muted | `#6b635c` | Comments, placeholders — same as `color8` |
| Foreground (bone) | `#d5cbbb` | Body text |
| Dark foreground | `#867d73` | |
| Light foreground | `#e3dacb` | |
| Bright foreground | `#efe8dc` | |
| **Accent (blood red)** | `#c1121f` | Primary accent, active border start |
| Accent tail (dried blood) | `#5a0d10` | Active border gradient end |
 
Active window border gradient: `rgba(c1121fff) rgba(5a0d10ff) 45deg`
Inactive window border: `rgba(2e2724ff)`
 
### Terminal colors (color0–color15), near-monochrome except red
 
```toml
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
```
 
### Alternate accent tried: Wraith (not adopted as the main theme)
 
Cold spectral blue-grey, built as a separate `hagalaz-wraith` theme copy so it could be compared side by side with blood red.
 
- Accent: `#7fa0b5`
- Accent tail: `#3c5566`
- Icon theme: `Yaru-blue` (vs. `Yaru-red` for the main theme)
- `color1` (red) was kept as-is even in this variant, so errors/urgent states still read as blood.
Other accent options explored in the HTML preview stage (for reference, not built out as full themes): Hellfire (`#e2591a`/`#b3161b`, the original ember pairing before blood red replaced it as the main accent), Bloodmoon (`#c1121f`/`#5a0d10`, this is what became the adopted blood-red palette), Plague (`#9fc04a`/`#3f5a1c`).
 
## Structural / look-and-feel decisions
 
- **Rounding:** 0 (sharp corners throughout)
- **Border size:** 3px (thick iron frame, not thin)
- **Gaps:** `gaps_in = 6`, `gaps_out = 12`
- **Blur:** on, but light — `size = 3`, `passes = 2`, `brightness = 0.7`
- **Dim inactive windows:** on, `dim_strength = 0.18`
- **Shadow:** `range = 24`, `render_power = 2`, color = accent at ~40% alpha (blood red: `rgba(c1121f66)` / Hyprland-Lua `0x66c1121f`)
- **Border animation:** `borderangle` loop, linear bezier, speed 30 — rotates the active gradient continuously as a stand-in for a flickering torch (Hyprland has no native flicker effect)
- **Bar position:** bottom (was the original design choice; also tested top)
- **Bar background:** solid, not transparent
## File-by-file inventory
 
Everything below was authored over the course of this conversation. Locations assume Omarchy 4 unless marked otherwise.
 
### Theme core
 
| File | Destination | Purpose |
|---|---|---|
| `colors.toml` | `~/.config/omarchy/themes/hagalaz/colors.toml` | The palette above. Omarchy 4 generates terminal/btop/Neovim/shell configs from this, including the two `hyprland_active_border` / `hyprland_inactive_border` keys. |
| `icons.theme` | `~/.config/omarchy/themes/hagalaz/icons.theme` | Contains `Yaru-red`; color-matches the file manager's icon set. |
| background image | `~/.config/omarchy/themes/hagalaz/backgrounds/` | User already had a suitable background before file generation started (castle/cathedral, dark, eclipse-style — matches an SVG mock-up built earlier of a castle-cathedral under a black sun, with crows, embers, and fog). |
 
### Omarchy 3.x-only files (kept for reference; **not** used since the user is on Omarchy 4)
 
| File | Destination | Purpose |
|---|---|---|
| `hyprland.conf` | `~/.config/omarchy/themes/hagalaz/hyprland.conf` | Sets the active/inactive border colors via Hyprlang, for versions where `colors.toml` doesn't drive Hyprland directly. |
| `frame-omarchy3.conf` | appended to `~/.config/hypr/looknfeel.conf` | The structural settings above (gaps, border size, rounding, blur, shadow, dim_inactive, borderangle) in Hyprlang syntax. |
 
### Omarchy 4 files (active)
 
| File | Destination | Purpose |
|---|---|---|
| `frame-omarchy4.lua` | appended to `~/.config/hypr/looknfeel.lua` (or wherever Hypr Lua overrides live) | Same structural settings as above, in Hyprland's Lua config format (`hl.config({...})`, `hl.curve`, `hl.animation`). Shadow color is an ARGB integer (`0x66c1121f`) rather than an `rgba()` string. |
 
### Yazi (terminal file manager) theme
 
| File | Destination | Purpose |
|---|---|---|
| `theme.toml` | `~/.config/yazi/theme.toml` | Static, rendered Yazi theme using the blood-red palette. Colors folders grey-blue, images teal, audio/video mauve, archives gold, broken symlinks red; blood-red highlights on the active row, tabs, mode indicator, and all popup borders. Written against Yazi 26.x's `[mgr]`/`[tabs]`/`[mode]`/`[status]`/etc. schema. |
| `yazi-theme.toml.tpl` | `~/.config/omarchy/themed/` | Same theme as an Omarchy template (`{{ accent }}`, `{{ color3 }}`, etc.) so it regenerates automatically on `omarchy-theme-set`, instead of needing manual edits when the palette changes. Requires symlinking Yazi's `theme.toml` to Omarchy's generated per-theme output — exact current-theme path differs by Omarchy version, wasn't confirmed on the user's machine. |
 
### Top bar (Omarchy 4 shell, Quickshell/QML)

The user is on Omarchy 4, which uses its own Quickshell-based shell (not Waybar). Bar contents live in `~/.config/omarchy/shell.json` under the `bar` key; once customized, that file is the sole source (no merge with defaults). The file is `private_` in chezmoi (mode 600).

Bar position is **top** (solid background). Layout ("Throne"):

- **left:** `local.rune-workspaces`, `niels.media`
- **center** (`centerAnchor: niels.clock`, mirrored): `omarchy.indicators` (hidden unless active or hovered), `local.hagalaz-moon`, `niels.clock` (`HH:mm`, right-click cycles to `ddd d MMM 'W'ww`), `local.hagalaz-pomodoro`
- **right:** `omarchy.tray`, `local.hagalaz-sysmon`, `omarchy.agents`, `omarchy.bluetooth`, `omarchy.network`, `omarchy.audio`, `omarchy.microphone`, `omarchy.monitor`, `omarchy.power`

`omarchy.keyboard-layout` and `omarchy.system-update` were removed on purpose.

**Theme tokens:** `themes/hagalaz/shell.toml` is a static copy of the generated shell.toml with these overrides: ash-black bar (`#0a0807`, same as apps; soot was tried and looked too light), blood `active`, bar height 30, iron hover/focus borders, red selected state, 2px blood-gradient popup and notification borders, and iron-framed tooltips. Re-apply with `omarchy theme set hagalaz` after editing.

**Font:** Grenze Gotisch (AUR `otf-grenze-gotisch`, listed under `packages.aur` and installed by `run_onchange_after_install-aur-packages.sh.tmpl` via yay). It's used for the clock label (15px), media titles (bar + popup), the sysmon bar label and popup headings, and the pomodoro countdown. The system mono font stays JetBrainsMono Nerd Font. Restart the shell (`omarchy restart shell`) after installing a font, because Qt only reads the font list at startup. Grenze defaults to **old-style numerals** (3/4/5/7/9 drop below the baseline), so every numeric Grenze label sets `font.features: { "lnum": 1, "tnum": 1 }`. `WidgetButton` can't pass features through, so those widgets hide its label (`labelVisible: false`) and draw their own `Text`.

| Plugin | Purpose |
|---|---|
| `niels.clock` | `omarchy plugin clone omarchy.clock`; the bar label uses Grenze Gotisch, `moduleName` is fixed to `niels.clock`, and the IPC target stays `omarchy.clock`. |
| `niels.media` | Clone of `omarchy.media`. Four organ pipes replace play/pause. While playing they show **live audio levels from cava** in blood red (`cava.conf`: 4 bars, 20fps, PipeWire, raw ascii to stdout, read with a `SplitParser`). When paused they lie low in the normal text color. cava runs only while something plays. If cava is missing, the pipes fall back to a slow decorative loop. Measured cost: about 6% shell CPU plus 1–2% for cava while playing, about 0% otherwise. Avoid `Behavior` animations on values that update every second (like the progress line): they keep the bar redrawing at 60fps. The bar shows the Grenze title, a red ᛫, and the dimmed artist, with a 2px blood progress line underneath (MPRIS position is polled every second). The popup has iron-framed cover art, a click-to-seek blood scrubber with timestamps, and a red pause button while playing. The popup also has a **24-pipe organ-facade visualizer** (`cava-popup.conf`: stereo, 30fps, halves reversed so the bass stands in the centre). The pipes sit in iron outlines that rise toward the middle and have a dark mouth notch. Only one cava runs at a time: the popup cava runs only while the popup is open and music plays, and it also feeds the bar pipes. Measured with the popup open: about 4% shell CPU, under 1% for cava, 14 MB. It adds `open()`/`opened` so `omarchy-shell shell summon niels.media` works. The marquee cap is 280px. The marquee is restarted explicitly on title, artist, width or popup changes, with `x` reset to 0 each time. This fixes an upstream bug where a stopped animation left the label offset, showing a blank gap and a clipped first word after a track change. It still uses the first-party `omarchy.media` service. |
| `local.hagalaz-sysmon` | Bar shows `ᛋ NN%  ᛗ NN%` (Sowilo/Mannaz; Kaunan ᚲ was too small) in Grenze, with a fixed width because Grenze digits are proportional, red past 85% CPU / 90% mem. Left click opens a popup (CPU per-core grid, temp, load; RAM/swap; NVIDIA util/temp/VRAM/power; disk + NVMe temp; top 5 processes; uptime). Right click opens btop. Data comes from the `stats` Python script (`--brief` for the bar). It finds the NVIDIA GPU by PCI vendor/class (no hardcoded address) and the CPU temperature from coretemp, then k10temp, zenpower, then acpitz, so it works on other machines. It doesn't call `nvidia-smi` while the dGPU is runtime-suspended, so polling doesn't wake it. |
| `local.hagalaz-moon` | Lunar phase computed locally (Nerd Font `nf-md-moon_*`); the tooltip shows % lit and the next full/new moon. |
| `local.hagalaz-pomodoro` | Candle timer: left = start/skip, right = pause, middle = reset; `workMinutes`/`breakMinutes` set inline in shell.json; sends a `notify-send` when a phase ends; the break is shown in dusty gold. |

Third-party widgets receive a `PluginBarApi` instead of the full bar. It has `run`, `foreground`, `urgent`, `fontFamily`, tooltips and popouts, but **no `shellQuote`**, so use `Util.shellQuote` from `qs.Commons`.

**Other machines (`chezmoi update`):** the files land as-is, then these scripts run in order:
1. `run_onchange_install-packages.sh.tmpl`: pacman packages, including `cava`.
2. `run_onchange_after_install-aur-packages.sh.tmpl`: `packages.aur` via yay.
3. `run_onchange_after_reload-omarchy-shell.sh.tmpl`: re-runs `omarchy theme set hagalaz` (if Hagalaz is the current theme) so the theme's `shell.toml` takes effect, then restarts the shell for the fonts and plugin code. It re-runs whenever the theme, the bar layout, any bar plugin file or the AUR list changes. Without a graphical session it prints what to run after logging in.

If Hagalaz isn't the active theme on that machine, run `omarchy theme set hagalaz` once.

### Rune workspace widget

A custom plugin, `local.rune-workspaces`, replaces the built-in `omarchy.workspaces` in the bar. It relabels the ten workspace slots with the first ten Elder Futhark runes (ᚠᚢᚦᚨᚱᚲᚷᚹᚺᚾ — workspace 9 = ᚺ = Hagalaz itself) and underlines the focused one in blood red. **Status: working** (glyphs render via Noto Sans Runic).

## Design reference (from the HTML mock-ups)
 
Two full HTML/CSS/SVG preview pages were built earlier as mood boards before any real Omarchy files were written. They are not part of the theme's installed files, but capture the intended visual target:
 
1. **Nocturne** — the initial cooler goth-cyberpunk direction (violet/magenta/cyan on near-black), later abandoned in favor of the warmer direction below.
2. **Dreadspire** — the dark-fantasy/evil-castle direction that Hagalaz is directly descended from. Established: firelit ember/hellfire palette (later swapped for blood red as the adopted accent), thick iron window frames with gold corner marks, dimmed inactive windows, a torch-flicker animation, bottom bar with rune workspace glyphs, an SVG wallpaper of a castle-cathedral under a black eclipse with crows/embers/fog/lightning, and an organ-pipe-style audio visualizer mock. Interactive controls in that page let the user compare "Hellfire / Bloodmoon / Plague / Wraith" accent pairings, bar top/bottom placement, border thickness, glow amount, and torch flicker on/off — Bloodmoon (blood red) is what got carried into the real theme.
## Naming
 
The theme was originally unnamed/described only by vibe, briefly went by the working title "Dreadspire" during the HTML mock-up stage, and was then formally named **Hagalaz** (ᚺ, an Elder Futhark rune) by the user's explicit instruction, which is also why workspace 9 in the rune widget is significant.
