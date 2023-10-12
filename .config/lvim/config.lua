-- Read the docs: https://www.lunarvim.org/docs/configuration
-- Example configs: https://github.com/LunarVim/starter.lvim
-- Video Tutorials: https://www.youtube.com/watch?v=sFA9kX-Ud_c&list=PLhoH5vyxr6QqGu0i7tt_XoVK9v-KvZ3m6
-- Forum: https://www.reddit.com/r/lunarvim/
-- Discord: https://discord.com/invite/Xb9B4Ny

vim.opt.cmdheight = 4 -- more space in the neovim command line for displaying messages
vim.opt.shiftwidth = 4 -- the number of spaces inserted for each indentation
vim.opt.tabstop = 4 -- insert 4 spaces for a tab
vim.opt.wrap = true -- wrap lines

vim.o.background = "dark"                               -- select colorscheme version (leave it empty to set vivid dark)
require('zeropro').load()                               -- colorscheme setup
lvim.colorscheme = "zeropro"

lvim.plugins = {
  { "lunarvim/colorschemes" },
  { "kdheepak/monochrome.nvim" },
  { "simrat39/rust-tools.nvim" },
  { "andweeb/presence.nvim"},
}

vim.cmd [[autocmd InsertEnter * :set norelativenumber]] -- relative numbers off at insert mode
vim.cmd [[autocmd InsertLeave * :set relativenumber]]
vim.cmd [[set cmdheight=1]]
vim.cmd [[set conceallevel=1]]

require("mason").setup()

local dap = require('dap')
local rt = require("rust-tools")
local mason_registry = require("mason-registry")

local codelldb = mason_registry.get_package("codelldb")
local extension_path = codelldb:get_install_path() .. "/extension/"
local codelldb_path = extension_path .. "adapter/codelldb"
local liblldb_path = extension_path .. "lldb/lib/liblldb.so"

rt.setup({
  dap = {
    adapter = require("rust-tools.dap").get_codelldb_adapter(codelldb_path, liblldb_path),
  },
  server = {
    capabilities = require("cmp_nvim_lsp").default_capabilities(),
    on_attach = function(_, bufnr)
      vim.keymap.set("n", "<Leader>k", rt.hover_actions.hover_actions, { buffer = bufnr })
      vim.keymap.set("n", "<Leader>a", rt.code_action_group.code_action_group, { buffer = bufnr })
    end,
  },
  tools = {
    hover_actions = {
      auto_focus = true,
    },
  },
})

dap.adapters.cppdbg = {
  id = 'cppdbg',
  type = 'executable',
  command = os.getenv("HOME") .. '/.config/lvim/cpptools/extension/debugAdapters/bin/OpenDebugAD7',
}
dap.configurations.cpp = {
  setupCommands = {
  {
     text = '-enable-pretty-printing',
     description =  'enable pretty printing',
     ignoreFailures = false
  },},
  {
    name = "Launch file",
    type = "cppdbg",
    request = "launch",
    program = function()
      return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
    end,
    cwd = '${workspaceFolder}',
    stopAtEntry = true,
  },
  {
    name = 'Attach to gdbserver :1234',
    type = 'cppdbg',
    request = 'launch',
    MIMode = 'gdb',
    miDebuggerServerAddress = 'localhost:1234',
    miDebuggerPath = '/usr/bin/gdb',
    cwd = '${workspaceFolder}',
    program = function()
      return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
    end,
  },
}
dap.configurations.c = dap.configurations.cpp

