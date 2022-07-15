--         .             .              .
--         |             |              |           .
-- ,-. ,-. |-. ,-. . ,-. |  ,_, ,-. ,-. |-. ,-,-. . |- ,_,
-- | | ,-| | | |   | |-' |   /  `-. |   | | | | | | |   /
-- `-| `-^ ^-' '   ' `-' `' '"' `-' `-' ' ' ' ' ' ' `' '"'
--  ,|
--  `'
-- GITHUB:https://github.com/gabrielzschmitz
-- INSTAGRAM:https://www.instagram.com/gabrielzschmitz_
-- DOTFILES:https://github.com/gabrielzschmitz/dotfiles
--
-- $HOME/.config/nvim/init.lua
--

-- Plugins
require('packer').startup(function()
    use 'wbthomason/packer.nvim'            -- packer itself
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
    use 'mg979/vim-visual-multi'            -- multi cursors
    use({
        "iamcco/markdown-preview.nvim",
        run = function() vim.fn["mkdp#util#install"]() end,
    })
    use {
        'nvim-lualine/lualine.nvim',
        requires = { 'kyazdani42/nvim-web-devicons', opt = true }
    }
end)

-- Visual
vim.o.background = "dark"                               -- select colorscheme version (leave it empty to set vivid dark)
require('zeropro').load()                               -- colorscheme setup
vim.cmd [[set noshowmode]]                              -- no --INSERT--
vim.cmd [[set termguicolors]]                           -- make nvim 256 colors
require'colorizer'.setup()                              -- enable colorizer
require('lualine').setup{
    options = {
        theme = 'zeropro',
        icons_enabled = true,
        section_separators = '',
        component_separators = '|'
    },
    sections = {
        lualine_a = {'mode'},
        lualine_b = {'branch', 'diff', 'diagnostics'},
        lualine_c = {'filename', 'filesize'},
        lualine_x = {'encoding', 'fileformat', 'filetype'},
        lualine_y = {'progress'},
        lualine_z = {'location'}
    }
}

-- General
vim.opt.swapfile = false            -- don't keep swap files
vim.opt.clipboard = "unnamedplus"   -- make nvim use system clipboard
vim.opt.mouse = "a"                 -- use mouse
vim.opt.number = true               -- active numbers
vim.cmd [[autocmd InsertEnter * :set norelativenumber]] -- relative numbers
vim.cmd [[autocmd InsertLeave * :set relativenumber]]
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

-- Markdown-preview
vim.cmd [[let g:mkdp_auto_start = 1]]
vim.cmd [[let g:mkdp_theme = 'dark']]
vim.cmd [[let g:mkdp_markdown_css = '/home/gabrielzschmitz/.config/nvim/plugin/zero.css']]

