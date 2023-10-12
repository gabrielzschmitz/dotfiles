local M = {}

function M.load(config)
    local config = config or require("zeropro.config").config
    local utils = require("zeropro.utils")

    local colors = require("zeropro.colors.zerodark").load()

    colors.name = "zerodark_vivid"
    colors.red = "#7c5380",
    colors.orange = "#b39970",
    colors.yellow = "#7f8066",
    colors.green = "#3c7073",
    colors.cyan = "#325d80",
    colors.blue = "#3f5273",
    colors.purple = "#634280",

    -- Allow colors to be overriden by the users config
    utils.color_overrides(colors, config)

    return colors
end

return M
