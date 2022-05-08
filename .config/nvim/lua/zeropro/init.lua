local M = {}

---Setup the theme via the default config or the users own
---@param user_config table
---@return table
function M.setup(user_config)
    return require("zeropro.config").set_config(user_config)
end

---Load the theme
---@param name string
---@return table
function M.load(name)
    local theme = require("zeropro.theme").setup_theme(name)
    return require("zeropro.utils").load_theme(theme)
end

---Get the color table for a specific theme (e.g. zerodark/zerolight).
---@param name string
---@return table
function M.get_colors(name)
    return vim.g.zeropro_colors or require("zeropro.colors").get_theme_colors(name)
end

return M
