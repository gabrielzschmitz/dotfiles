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
-- $HOME/.config/nvim/keybinds.lua
--

-- Native nvim
vim.g.mapleader = ","   -- leader key

-- LSP
local keymap = vim.api.nvim_set_keymap  -- easier keymapping
local opts = { noremap = true }
local function nkeymap(key, map)
	keymap('n', key, map, opts)
end

nkeymap('gd', ':lua vim.lsp.buf.definition()<cr>')          -- go to definition
nkeymap('gD', ':lua vim.lsp.buf.declaration()<cr>')         -- go to declaration
nkeymap('gi', ':lua vim.lsp.buf.implementation()<cr>')      -- go to implementation
nkeymap('gw', ':lua vim.lsp.buf.document_symbol()<cr>')     -- go to document symbol
nkeymap('gw', ':lua vim.lsp.buf.workspace_symbol()<cr>')    -- go to workspace symbol
nkeymap('gr', ':lua vim.lsp.buf.references()<cr>')          -- go to references
nkeymap('gt', ':lua vim.lsp.buf.type_definition()<cr>')     -- go to type definition
nkeymap('K', ':lua vim.lsp.buf.hover()<cr>')                -- show function under cursor
nkeymap('<c-k>', ':lua vim.lsp.buf.signature_help()<cr>')   -- show signature help
nkeymap('<leader>af', ':lua vim.lsp.buf.code_action()<cr>') -- code action
nkeymap('<leader>rn', ':lua vim.lsp.buf.rename()<cr>')      -- funtion rename

