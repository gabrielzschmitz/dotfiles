local colors = require("zeropro").get_colors()

local zeropro = {}

zeropro.normal = {
    a = { bg = colors.green, fg = colors.bg },
    b = { bg = colors.bg_statusline, fg = colors.green },
    c = { bg = colors.bg_statusline, fg = colors.fg },
    x = { bg = colors.bg_statusline, fg = colors.fg },
    y = { bg = colors.bg_statusline, fg = colors.fg },
    z = { bg = colors.green, fg = colors.bg },
}

zeropro.insert = {
    a = { bg = colors.cyan, fg = colors.bg },
    b = { bg = colors.bg_statusline, fg = colors.blue },
    c = { bg = colors.bg_statusline, fg = colors.fg },
    x = { bg = colors.bg_statusline, fg = colors.fg },
    y = { bg = colors.bg_statusline, fg = colors.fg },
    z = { bg = colors.cyan, fg = colors.bg },
}

zeropro.command = {
    a = { bg = colors.fg, fg = colors.bg },
    b = { bg = colors.bg_statusline, fg = colors.purple },
    c = { bg = colors.bg_statusline, fg = colors.fg },
    x = { bg = colors.bg_statusline, fg = colors.fg },
    y = { bg = colors.bg_statusline, fg = colors.fg },
    z = { bg = colors.fg, fg = colors.bg },
}

zeropro.visual = {
    a = { bg = colors.yellow, fg = colors.bg },
    b = { bg = colors.bg_statusline, fg = colors.yellow },
    c = { bg = colors.bg_statusline, fg = colors.fg },
    x = { bg = colors.bg_statusline, fg = colors.fg },
    y = { bg = colors.bg_statusline, fg = colors.fg },
    z = { bg = colors.yellow, fg = colors.bg },
}

zeropro.replace = {
    a = { bg = colors.purple, fg = colors.bg },
    b = { bg = colors.bg_statusline, fg = colors.red },
    c = { bg = colors.bg_statusline, fg = colors.fg },
    x = { bg = colors.bg_statusline, fg = colors.fg },
    y = { bg = colors.bg_statusline, fg = colors.fg },
    z = { bg = colors.purple, fg = colors.bg },
}

zeropro.inactive = {
    a = { bg = colors.bg_statusline, fg = colors.blue },
    b = { bg = colors.bg_statusline, fg = colors.fg, gui = "bold" },
    c = { bg = colors.bg_statusline, fg = colors.fg },
    x = { bg = colors.bg_statusline, fg = colors.fg },
    y = { bg = colors.bg_statusline, fg = colors.fg },
    z = { bg = colors.bg_statusline, fg = colors.blue },
}

return zeropro
