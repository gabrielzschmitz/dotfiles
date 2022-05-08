local M = {}

function M.load(config)
    local config = config or require("zeropro.config").config
    local utils = require("zeropro.utils")

    local colors = require("zeropro.colors.zerodark").load()

    colors.name = "zerodark_vivid"
    colors.red = "#634266"
    colors.orange = "#998360"
    colors.yellow = "#73725c"
    colors.green = "#2e5659"
    colors.cyan = "#285266"
    colors.blue = "#344b73"
    colors.purple = "#513c66"

    -- Allow colors to be overriden by the users config
    utils.color_overrides(colors, config)

    return colors
end

return M
