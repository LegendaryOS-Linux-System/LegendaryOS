local wezterm = require("wezterm")
local config  = wezterm.config_builder()

-- ── Kolory — LegendaryOS Dark Cyber Theme ────────────────────────────────────
-- Inspiracja: strona legendaryos-linux-system.github.io
-- Tło: głęboka czerń (#0a0a0f) jak tło strony
-- Akcenty: cyan (#00d4ff) i niebieski (#3b82f6) — kolory hexagonów i przycisków
-- Tekst: jasny biały (#e2e8f0)

config.colors = {
    -- Tło terminala — taki sam głęboki granat jak strona
    background    = "#0a0a0f",
    foreground    = "#e2e8f0",

        -- Kursor — cyan accent z witryny
        cursor_bg     = "#00d4ff",
        cursor_fg     = "#0a0a0f",
        cursor_border = "#00d4ff",

        -- Zaznaczenie
        selection_bg  = "#1e3a5f",
        selection_fg  = "#e2e8f0",

        -- 16 kolorów ANSI
        ansi = {
            "#1a1a2e",   -- black   (ciemny granat jak panel terminala na stronie)
            "#ef4444",   -- red     (błędy)
            "#22c55e",   -- green   (sukces — OK z buildera)
            "#f59e0b",   -- yellow  (ostrzeżenia — ⚠)
            "#3b82f6",   -- blue    (główny akcent — przyciski POBIERZ)
            "#8b5cf6",   -- magenta (secondary accent)
            "#00d4ff",   -- cyan    (główny hex accent — ⬣ LegendaryOS)
            "#e2e8f0",   -- white   (tekst)
        },
        brights = {
            "#2d2d4e",   -- bright black  (komentarze, dim text)
            "#f87171",   -- bright red
            "#4ade80",   -- bright green
            "#fbbf24",   -- bright yellow
            "#60a5fa",   -- bright blue
            "#a78bfa",   -- bright magenta
            "#67e8f9",   -- bright cyan   (podświetlony akcent)
            "#f8fafc",   -- bright white  (czysto biały)
        },

        -- Pasek zakładek
        tab_bar = {
            background = "#06060f",

            active_tab = {
                bg_color  = "#0a0a0f",
                fg_color  = "#00d4ff",
                intensity = "Bold",
            },
            inactive_tab = {
                bg_color = "#0d0d1a",
                fg_color = "#4a5568",
            },
            inactive_tab_hover = {
                bg_color = "#111128",
                fg_color = "#94a3b8",
            },
            new_tab = {
                bg_color = "#06060f",
                fg_color = "#3b82f6",
            },
            new_tab_hover = {
                bg_color = "#06060f",
                fg_color = "#00d4ff",
            },
        },
}

-- ── Czcionka ──────────────────────────────────────────────────────────────────
-- JetBrains Mono — zainstalowana przez install.packages, idealna dla terminala
-- Fallback: Fira Code, Cascadia Code (też zainstalowane)
config.font = wezterm.font_with_fallback({
    {
        family   = "JetBrains Mono",
        weight   = "Regular",
        harfbuzz_features = { "calt=1", "liga=1", "zero=1" }, -- ligatury
    },
    { family = "Fira Code",    weight = "Regular" },
    { family = "Cascadia Code", weight = "Regular" },
    { family = "monospace" },
})

config.font_size            = 12.0
config.line_height          = 1.15
config.cell_width           = 1.0
config.freetype_load_target = "Light"    -- wyraźniejszy rendering
config.freetype_render_target = "HorizontalLcd"

-- ── Okno ─────────────────────────────────────────────────────────────────────
config.window_background_opacity  = 0.92   -- lekka przezroczystość — nowoczesny efekt
config.text_background_opacity     = 1.0
config.window_background_gradient = nil    -- wyłącz gradient (solid color)

-- Blur tła (Wayland/KDE Plasma)
config.macos_window_background_blur = 20   -- macOS
config.win32_system_backdrop        = "Acrylic" -- Windows fallback

config.window_padding = {
    left   = 14,
    right  = 14,
    top    = 10,
    bottom = 10,
}

config.initial_cols = 120
config.initial_rows = 35

-- Dekoracje okna — minimalistyczne, pasuje do dark UI
config.window_decorations = "RESIZE"  -- bez standardowego titlebar, tylko resize

-- ── Pasek zakładek ────────────────────────────────────────────────────────────
config.use_fancy_tab_bar       = false   -- prosty pasek — lepiej pasuje do dark theme
config.tab_bar_at_bottom       = false
config.hide_tab_bar_if_only_one_tab = true
config.tab_max_width           = 32
config.show_tab_index_in_tab_bar = false

-- Format zakładki — z ikoną ⬣ nawiązującą do logo LegendaryOS
wezterm.on("format-tab-title", function(tab, tabs, panes, cfg, hover, max_width)
local title = tab.active_pane.title
if tab.tab_title and #tab.tab_title > 0 then
    title = tab.tab_title
    end
    -- Skróć długie tytuły
    if #title > max_width - 4 then
        title = title:sub(1, max_width - 5) .. "…"
        end
        local is_active = tab.is_active
        return {
            { Text = is_active and " ⬡ " or "   " },
            { Text = title .. " " },
        }
        end)

-- ── Status bar — LegendaryOS branding ────────────────────────────────────────
wezterm.on("update-status", function(window, pane)
local cells = {}

-- Czas
local time = wezterm.strftime("%H:%M")
table.insert(cells, { Foreground = { Color = "#4a5568" } })
table.insert(cells, { Text = "  " .. time .. "  " })

-- LegendaryOS badge
table.insert(cells, { Foreground = { Color = "#00d4ff" } })
table.insert(cells, { Background = { Color = "#06060f" } })
table.insert(cells, { Text = " ⬡ LegendaryOS " })

window:set_right_status(wezterm.format(cells))
end)

-- ── Kursor ────────────────────────────────────────────────────────────────────
config.default_cursor_style   = "BlinkingBar"   -- migający pasek — nowoczesny look
config.cursor_blink_rate      = 500             -- ms
config.cursor_blink_ease_in   = "Constant"
config.cursor_blink_ease_out  = "Constant"

-- ── Zachowanie ────────────────────────────────────────────────────────────────
config.scrollback_lines        = 10000
config.enable_scroll_bar       = false          -- clean look bez scrollbara
config.check_for_updates       = false          -- off — aktualizacje przez dnf
config.audible_bell            = "Disabled"
config.visual_bell = {
    fade_in_duration_ms  = 75,
    fade_out_duration_ms = 75,
    target = "CursorColor",
}

-- ── Shell ─────────────────────────────────────────────────────────────────────
-- bash jako domyślny (zsh/fish można dodać samemu)
config.default_prog = { "/bin/bash", "--login" }

-- ── Keybindings — intuicyjne skróty ─────────────────────────────────────────
local act = wezterm.action

config.keys = {
    -- Nowa zakładka
    { key = "t",     mods = "CTRL|SHIFT", action = act.SpawnTab("CurrentPaneDomain") },
    -- Zamknij zakładkę
    { key = "w",     mods = "CTRL|SHIFT", action = act.CloseCurrentTab({ confirm = false }) },
    -- Poprzednia/następna zakładka
    { key = "Tab",   mods = "CTRL",       action = act.ActivateTabRelative(1) },
    { key = "Tab",   mods = "CTRL|SHIFT", action = act.ActivateTabRelative(-1) },
    -- Podział poziomy
    { key = "\\",    mods = "CTRL|SHIFT", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
    -- Podział pionowy
    { key = "-",     mods = "CTRL|SHIFT", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },
    -- Powiększenie/zmniejszenie czcionki
    { key = "=",     mods = "CTRL",       action = act.IncreaseFontSize },
    { key = "-",     mods = "CTRL",       action = act.DecreaseFontSize },
    { key = "0",     mods = "CTRL",       action = act.ResetFontSize },
    -- Kopiuj/wklej
    { key = "c",     mods = "CTRL|SHIFT", action = act.CopyTo("Clipboard") },
    { key = "v",     mods = "CTRL|SHIFT", action = act.PasteFrom("Clipboard") },
    -- Pełny ekran
    { key = "F11",   mods = "",           action = act.ToggleFullScreen },
    -- Szybkie przejście do zakładki
    { key = "1",     mods = "ALT",        action = act.ActivateTab(0) },
    { key = "2",     mods = "ALT",        action = act.ActivateTab(1) },
    { key = "3",     mods = "ALT",        action = act.ActivateTab(2) },
    { key = "4",     mods = "ALT",        action = act.ActivateTab(3) },
    { key = "5",     mods = "ALT",        action = act.ActivateTab(4) },
}

-- Scroll kółkiem myszy
config.mouse_bindings = {
    {
        event  = { Down = { streak = 1, button = { WheelUp = 1 } } },
        mods   = "NONE",
        action = act.ScrollByLine(-3),
    },
    {
        event  = { Down = { streak = 1, button = { WheelDown = 1 } } },
        mods   = "NONE",
        action = act.ScrollByLine(3),
    },
}

-- ── Renderowanie ──────────────────────────────────────────────────────────────
config.front_end            = "WebGpu"   -- GPU rendering (Wayland + NVIDIA)
config.webgpu_power_preference = "HighPerformance"
config.animation_fps        = 60
config.max_fps              = 120

return config
