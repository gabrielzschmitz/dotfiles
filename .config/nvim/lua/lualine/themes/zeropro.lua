local colors = require("zeropro").get_colors()

local zeropro = {}

zeropro.normal = {
    a = { bg = colors.green, fg = colors.bg },
    b = { bg = colors.fg_gutter, fg = colors.green },
    c = { bg = colors.bg_statusline, fg = colors.fg_sidebar },
}

zeropro.insert = {
    a = { bg = colors.blue, fg = colors.bg },
    b = { bg = colors.fg_gutter, fg = colors.blue },
}

zeropro.command = {
    a = { bg = colors.purple, fg = colors.bg },
    b = { bg = colors.fg_gutter, fg = colors.purple },
}

zeropro.visual = {
    a = { bg = colors.yellow, fg = colors.bg },
    b = { bg = colors.fg_gutter, fg = colors.yellow },
}

zeropro.replace = {
    a = { bg = colors.red, fg = colors.bg },
    b = { bg = colors.fg_gutter, fg = colors.red },
}

zeropro.inactive = {
    a = { bg = colors.bg_statusline, fg = colors.blue },
    b = { bg = colors.bg_statusline, fg = colors.fg_gutter, gui = "bold" },
    c = { bg = colors.bg_statusline, fg = colors.fg_gutter },
}

return zeropro
