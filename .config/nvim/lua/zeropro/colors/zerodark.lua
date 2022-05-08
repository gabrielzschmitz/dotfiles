local M = {}

function M.load(config)
    local config = config or require("zeropro.config").config
    local utils = require("zeropro.utils")

    local colors = {
        name = "zerodark",

        bg = "#080808",
        fg = "#e5e5e5",
        red = "#644d66",
        orange = "#998970",
        yellow = "#736871",
        green = "#375759",
        cyan = "#324f66",
        blue = "#3f5273",
        purple = "#564666",
        white = "#b3b3b3",
        black = "#080808",
        gray = "#b3b3b3",
        highlight = "#141414",
        none = "NONE",
    }

    -- Allow colors to be overriden by the users config
    utils.color_overrides(colors, config)

    -- Additional colors
    colors.cursorline = colors.cursorline or utils.lighten(colors.bg, 0.97)
    colors.color_column = colors.color_column or utils.lighten(colors.bg, 0.97)
    colors.comment = colors.comment or utils.lighten(colors.gray, 0.80)
    colors.indentline = colors.indentline or utils.lighten(colors.bg, 0.93)
    colors.menu = colors.menu or utils.lighten(colors.bg, 0.90)
    colors.menu_scroll = colors.menu_scroll or utils.lighten(colors.bg, 0.95)
    colors.menu_scroll_thumb = colors.menu_scroll_thumb or utils.darken(colors.blue, 0.80)
    colors.selection = colors.selection or utils.lighten(colors.bg, 0.8)

    -- Git diff
    colors.diff_add = colors.diff_add or "#324f66"
    colors.diff_delete = colors.diff_delete or "#564666"
    colors.diff_text = colors.diff_text or "#324f66"

    -- Lualine colors
    colors.bg_statusline = colors.bg_statusline or utils.lighten(colors.bg, 0.95)
    colors.fg_gutter = colors.fg_gutter or utils.lighten(colors.bg, 0.70)
    colors.fg_sidebar = colors.fg_sidebar or colors.fg

    -- Virtual text
    colors.virtual_text_error = colors.virtual_text_error or utils.lighten(colors.red, 0.7)
    colors.virtual_text_warning = colors.virtual_text_warning or utils.lighten(colors.yellow, 0.7)
    colors.virtual_text_information = colors.virtual_text_information or utils.lighten(colors.blue, 0.7)
    colors.virtual_text_hint = colors.virtual_text_hint or utils.lighten(colors.cyan, 0.8)

    return colors
end

return M
