local M = {}

function M.load(config)
    local config = config or require("zeropro.config").config
    local utils = require("zeropro.utils")

    local colors = {
        name = "zerolight",

        bg = "#fafafa",
        fg = "#212121",
        red = "#7b4d80",
        orange = "#b39568",
        yellow = "#8c6a87",
        green = "#366f73",
        cyan = "#2a5a80",
        blue = "#38578c",
        purple = "#634580",
        white = "#808080",
        black = "#212121",
        gray = "#808080",
        highlight = "#2e2e2e",
        none = "NONE",
    }

    -- Allow colors to be overriden by the users config
    utils.color_overrides(colors, config)

    -- Additional colors
    colors.cursorline = colors.cursorline or utils.darken(colors.bg, 0.97)
    colors.color_column = colors.color_column or utils.darken(colors.bg, 0.97)
    colors.comment = colors.comment or utils.darken(colors.gray, 0.80)
    colors.indentline = colors.indentline or utils.darken(colors.bg, 0.93)
    colors.menu = colors.menu or utils.darken(colors.bg, 0.95)
    colors.menu_scroll = colors.menu_scroll or utils.darken(colors.bg, 0.90)
    colors.menu_scroll_thumb = colors.menu_scroll_thumb or utils.lighten(colors.blue, 0.80)
    colors.selection = colors.selection or utils.darken(colors.bg, 0.90)

    -- Git diff
    colors.diff_add = colors.diff_add or "#2a5a80"
    colors.diff_delete = colors.diff_delete or "#634580"
    colors.diff_text = colors.diff_text or "#2a5a80"

    -- Lualine colors
    colors.bg_statusline = colors.bg_statusline or utils.darken(colors.bg, 0.95)
    colors.fg_gutter = colors.fg_gutter or utils.darken(colors.bg, 0.70)
    colors.fg_sidebar = colors.fg_sidebar or colors.fg

    -- Virtual text
    colors.virtual_text_error = colors.virtual_text_error or utils.lighten(colors.red, 0.6)
    colors.virtual_text_warning = colors.virtual_text_warning or utils.lighten(colors.yellow, 0.6)
    colors.virtual_text_information = colors.virtual_text_information or utils.lighten(colors.blue, 0.6)
    colors.virtual_text_hint = colors.virtual_text_hint or utils.lighten(colors.cyan, 0.6)

    return colors
end

return M
