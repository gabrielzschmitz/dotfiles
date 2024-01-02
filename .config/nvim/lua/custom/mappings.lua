local M = {}

M.dap = {
  plugin = true,
  n = {
    ["<leader>db"] = {
      "<cmd> DapToggleBreakpoint <CR>",
      "Add breakpoint at line",
    },
    ["<leader>dr"] = {
      "<cmd> DapContinue <CR>",
      "Start or continue the debugger",
    }
  }
}

local function map(mode, lhs, rhs, opts)
    local options = { noremap = true, silent = true }
    if opts then
        if opts.desc then
            opts.desc = "keymaps.lua: " .. opts.desc
        end
        options = vim.tbl_extend('force', options, opts)
    end
    vim.keymap.set(mode, lhs, rhs, options)
end
map("n", "<C-k>", "<C-w>k", { desc = "Jump to up split"})
map("n", "<C-j>", "<C-w>j", { desc = "Jump to down split"})
map("n", "<C-h>", "<C-w>h", { desc = "Jump to left split"})
map("n", "<C-l>", "<C-w>l", { desc = "Jump to right split"})

map("n", "<C-Up>", ":resize +3 <CR>", { desc = "Resize split to up", silent = true })
map("n", "<C-Down>", ":resize -3 <CR>", { desc = "Resize split to down", silent = true })
map("n", "<C-Left>", ":vertical resize +3 <CR>", { desc = "Resize split to left", silent = true })
map("n", "<C-Right>", ":vertical resize -3 <CR>", { desc = "Resize split to right", silent = true })

M.dap_python = {
  plugin = true,
  n = {
    ["<leader>dpr"] = {
      function()
        require('dap-python').test_method()
      end
    }
  }
}

return M
