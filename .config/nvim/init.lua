--         .             .              .                  
--         |             |              |           .      
-- ,-. ,-. |-. ,-. . ,-. |  ,_, ,-. ,-. |-. ,-,-. . |- ,_, 
-- | | ,-| | | |   | |-' |   /  `-. |   | | | | | | |   /  
-- `-| `-^ ^-' '   ' `-' `' '"' `-' `-' ' ' ' ' ' ' `' '"' 
--  ,|                                                     
--  `'                                                     
-- GITHUB:https://github.com/gabrielzschmitz               
-- INSTAGRAM:https://www.instagram.com/gabrielzschmitzzz/  
-- DOTFILES:https://github.com/gabrielzschmitz/dotfiles/   
--
-- $HOME/.config/nvim/init.lua
--

-- Plugins
require('packer').startup(function()
    use 'wbthomason/packer.nvim'            -- packer itself
    use 'itchyny/lightline.vim'             -- lightline
    use 'nvim-treesitter/nvim-treesitter'   -- treesitter
    use 'norcalli/nvim-colorizer.lua'       -- colorizer
    use 'williamboman/nvim-lsp-installer'   -- lsp installer
    use 'neovim/nvim-lspconfig'             -- lsp config
    use 'hrsh7th/cmp-nvim-lsp'              -- lsp completion
    use 'hrsh7th/cmp-buffer'                -- lsp completion
    use 'hrsh7th/cmp-path'                  -- lsp completion
    use 'hrsh7th/cmp-cmdline'               -- lsp completion
    use 'hrsh7th/nvim-cmp'                  -- lsp completion
    use 'windwp/nvim-autopairs'             -- autopair
end)

-- Visual
require('zeropro').load()                               -- colorscheme
vim.cmd [[let g:lightline = { 'colorscheme': 'zero' }]] -- lightline colorscheme
vim.cmd [[set noshowmode]]                              -- no --INSERT--
vim.cmd [[set termguicolors]]                           -- make nvim 256 colors
require'colorizer'.setup()                              -- enable colorizer

-- General
vim.opt.swapfile = false            -- don't keep swap files
vim.opt.clipboard = "unnamedplus"   -- make nvim use system clipboard
vim.opt.mouse = "a"                 -- use mouse
vim.opt.number = true               -- active numbers
vim.opt.relativenumber = true       -- relative numbers
vim.opt.cursorline = true           -- colorized cursorline
vim.opt.wrap = true                 -- wrap lines
vim.opt.updatetime = 300            -- make updates faster
vim.opt.hidden = true               -- set hidden buffers
vim.opt.autoindent = true           -- auto indent
vim.opt.smartindent = true          -- smart indenting
vim.opt.ignorecase = true           -- case insensitive
vim.opt.smartcase = true            -- smart case insensitive
vim.opt.smarttab = true             -- smart tabs
vim.opt.expandtab = true            -- set 4 spaces for tab
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4

-- Treesitter
local configs = require'nvim-treesitter.configs'
configs.setup {
    ensure_installed = "all",   -- use all parsers
    ingore_install = "phpdoc",  -- unless this one
    highlight = {               -- enable highlighting
        enable = true,
    },
    indent = {                  -- enable indentation
        enable = true,
    }
}

-- Autopairs
require('nvim-autopairs').setup{}

-- Keybinds
require('user.keybinds') -- call keybinds

-- LSP Completion
require('user.lsp')

