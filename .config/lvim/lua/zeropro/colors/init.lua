local M = {}

M.themes = {
    "zerodark",
    "zerolight",
    "zerodark_vivid",
}

---Return the color table for one of the two themes
---@param name string
---@return table
function M.get_theme_colors(name)
    name = name or require("zeropro.config").config.theme

    if type(name) == "function" then
        name = name()
    end

    if vim.tbl_contains(M.themes, name) then
        return require("zeropro.colors." .. name).load()
    end

    -- NOTE: This file is loaded many times if the user calls the get_colors method
    vim.cmd(
        "echohl WarningMsg | echom \"zeropro.nvim: Could not find theme '"
            .. name
            .. "'. Loading zero instead\" | echohl NONE"
    )
    return require("zeropro.colors.zero").load()
end

return M
