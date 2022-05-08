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
    use 'neovim/nvim-lspconfig'             -- lsp config
    use 'williamboman/nvim-lsp-installer'   -- lsp installer
    use 'hrsh7th/cmp-nvim-lsp'              -- lsp completion
    use 'hrsh7th/cmp-buffer'                -- lsp completion
    use 'hrsh7th/cmp-path'                  -- lsp completion
    use 'hrsh7th/cmp-cmdline'               -- lsp completion
    use 'hrsh7th/nvim-cmp'                  -- lsp completion
end)

-- Visual
require('zeropro').load()                               -- colorscheme
vim.cmd [[let g:lightline = { 'colorscheme': 'zero' }]] -- lightline colorscheme
vim.cmd [[set noshowmode]]                              -- no --INSERT--
vim.cmd [[set termguicolors]]                           -- make nvim 256 colors
require'colorizer'.setup()                              -- enable colorizer

-- General
vim.cmd [[set noswapfile]]      -- don't keep swap files
vim.o.clipboard = "unnamedplus" -- make nvim use system clipboard
vim.cmd [[set mouse=a]]         -- use mouse
vim.wo.number = true            -- active numbers
vim.wo.relativenumber = true    -- relative numbers
vim.wo.cursorline = true        -- colorized cursorline
vim.wo.wrap = true              -- wrap lines
vim.o.hidden = true             -- set hidden buffers
vim.bo.autoindent = true        -- auto indent
vim.o.ignorecase = true         -- case insensitive
vim.o.smartcase = true          -- smart case insensitive
vim.o.smarttab = true           -- smart tabs
vim.bo.expandtab = true         -- set 4 spaces for tab
vim.bo.shiftwidth = 4
vim.bo.softtabstop = 4

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

-- Keybinds
require('keybinds') -- call keybinds

-- LSP Server
require('lsp')      -- call lsp configuration

