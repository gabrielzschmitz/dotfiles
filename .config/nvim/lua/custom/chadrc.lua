---@type ChadrcConfig
local M = {}

M.ui = {
  theme_toggle = { "catppuccin", "blossom_light" },
  theme = "catppuccin",
  transparency = false,
  statusline = {
    theme = "default",
    separator_style = "default",
    overriden_modules = nil,
  },
  tabufline = {
    lazyload = false,
    overriden_modules = nil,
  },
}
M.plugins = "custom.plugins"
M.mappings = require("custom.mappings")

return M
