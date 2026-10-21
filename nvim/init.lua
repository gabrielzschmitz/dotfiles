-- ============================================================================
--  ██████   █████                   █████   █████  ███
-- ░░██████ ░░███                   ░░███   ░░███  ░░░
--  ░███░███ ░███   ██████   ██████  ░███    ░███  ████  █████████████
--  ░███░░███░███  ███░░███ ███░░███ ░███    ░███ ░░███ ░░███░░███░░███
--  ░███ ░░██████ ░███████ ░███ ░███ ░░███   ███   ░███  ░███ ░███ ░███
--  ░███  ░░█████ ░███░░░  ░███ ░███  ░░░█████░    ░███  ░███ ░███ ░███
--  █████  ░░█████░░██████ ░░██████     ░░███      █████ █████░███ █████
-- ░░░░░    ░░░░░  ░░░░░░   ░░░░░░       ░░░      ░░░░░ ░░░░░ ░░░ ░░░░░
--
-------------------------------------------------------------------------------
--  Neovim configuration
--  Managed by Home Manager / NixOS
-- ============================================================================

-- ============================================================================
-- OPTIONS
-- ============================================================================

vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.opt.number = true
vim.opt.relativenumber = true

vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.softtabstop = 2

vim.opt.smartindent = true
vim.opt.wrap = false

vim.opt.termguicolors = true

vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.opt.cursorline = true

vim.opt.signcolumn = "yes"

vim.opt.splitright = true
vim.opt.splitbelow = true

vim.opt.scrolloff = 8
vim.opt.sidescrolloff = 8

vim.opt.updatetime = 250
vim.opt.timeoutlen = 500
vim.opt.ttimeoutlen = 10

vim.opt.mouse = "a"

vim.opt.clipboard = "unnamedplus"

vim.opt.completeopt = {
	"menu",
	"menuone",
	"noselect",
}

vim.opt.undofile = true

-- ============================================================================
-- DIAGNOSTICS
-- ============================================================================

vim.diagnostic.config({
	virtual_text = true,
	signs = true,
	underline = true,
	update_in_insert = false,
	severity_sort = true,

	float = {
		border = "rounded",
		source = "if_many",
	},
})

-- ============================================================================
-- NETRW
-- ============================================================================

-- nvim-tree recommends disabling netrw when using nvim-tree.
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- ============================================================================
-- LAZY.NVIM
-- ============================================================================

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable",
		lazypath,
	})
end

vim.opt.rtp:prepend(lazypath)

-- ============================================================================
-- PLUGINS
-- ============================================================================

require("lazy").setup({
	----------------------------------------------------------------------
	-- THEME
	----------------------------------------------------------------------

	{
		"navarasu/onedark.nvim",

		priority = 1000,

		config = function()
			require("onedark").setup({
				style = "dark",
				transparent = true,
				lualine = {
					transparent = true,
				},
			})

			require("onedark").load()
		end,
	},

	----------------------------------------------------------------------
	-- FILE EXPLORER
	----------------------------------------------------------------------

	{
		"nvim-tree/nvim-tree.lua",

		lazy = false,

		dependencies = {
			"nvim-tree/nvim-web-devicons",
		},

		config = function()
			require("nvim-tree").setup({
				sort = {
					sorter = "case_sensitive",
				},

				view = {
					width = 30,
				},

				renderer = {
					group_empty = true,
				},

				filters = {
					dotfiles = false,
				},
			})
		end,
	},

	----------------------------------------------------------------------
	-- LSP
	----------------------------------------------------------------------

	{
		"neovim/nvim-lspconfig",

		config = function()
			local capabilities = require("mini.completion").get_lsp_capabilities()

			--------------------------------------------------------------------
			-- Lua
			--------------------------------------------------------------------

			vim.lsp.config("lua_ls", {
				capabilities = capabilities,

				filetypes = {
					"lua",
				},

				settings = {
					Lua = {
						diagnostics = {
							globals = {
								"vim",
							},
						},

						workspace = {
							checkThirdParty = false,
						},

						telemetry = {
							enable = false,
						},
					},
				},
			})

			--------------------------------------------------------------------
			-- Nix
			--------------------------------------------------------------------

			vim.lsp.config("nixd", {
				capabilities = capabilities,

				cmd = {
					"nixd",
				},

				filetypes = {
					"nix",
				},

				root_markers = {
					"flake.nix",
					".git",
				},

				settings = {
					nixd = {
						nixpkgs = {
							expr = "import <nixpkgs> { }",
						},

						formatting = {
							command = {
								"nixfmt",
							},
						},

						options = {
							nixos = {
								expr = "(builtins.getFlake (toString ./.)).nixosConfigurations.nixos.options",
							},

							home_manager = {
								expr = "(builtins.getFlake (toString ./.)).homeConfigurations.gabrielzschmitz.options",
							},
						},
					},
				},
			})

			--------------------------------------------------------------------
			-- HTML
			--------------------------------------------------------------------

			vim.lsp.config("html", {
				capabilities = capabilities,

				filetypes = {
					"html",
				},
			})

			--------------------------------------------------------------------
			-- CSS
			--------------------------------------------------------------------

			vim.lsp.config("cssls", {
				capabilities = capabilities,

				filetypes = {
					"css",
					"scss",
					"less",
				},
			})

			--------------------------------------------------------------------
			-- C / C++
			--------------------------------------------------------------------

			vim.lsp.config("clangd", {
				capabilities = capabilities,

				cmd = {
					"clangd",
					"--background-index",
					"--clang-tidy",
					"--header-insertion=iwyu",
					"--completion-style=detailed",
				},

				filetypes = {
					"c",
					"cpp",
					"objc",
					"objcpp",
				},
			})

			--------------------------------------------------------------------
			-- Go
			--------------------------------------------------------------------

			vim.lsp.config("gopls", {
				capabilities = capabilities,

				cmd = {
					"gopls",
				},

				filetypes = {
					"go",
					"gomod",
					"gowork",
					"gotmpl",
				},

				settings = {
					gopls = {
						gofumpt = true,
						staticcheck = true,

						analyses = {
							unusedparams = true,
							shadow = true,
							nilness = true,
							unusedwrite = true,
							useany = true,
						},

						hints = {
							assignVariableTypes = true,
							compositeLiteralFields = true,
							compositeLiteralTypes = true,
							constantValues = true,
							functionTypeParameters = true,
							parameterNames = true,
							rangeVariableTypes = true,
						},
					},
				},
			})

			--------------------------------------------------------------------
			-- Go lint
			--------------------------------------------------------------------

			vim.lsp.config("golangci_lint_ls", {
				capabilities = capabilities,

				filetypes = {
					"go",
					"gomod",
					"gowork",
				},
			})

			--------------------------------------------------------------------
			-- Python / Ruff
			--------------------------------------------------------------------

			vim.lsp.config("ruff", {
				capabilities = capabilities,

				filetypes = {
					"python",
				},
			})

			--------------------------------------------------------------------
			-- Enable LSP servers
			--------------------------------------------------------------------

			vim.lsp.enable({
				"nixd",
				"lua_ls",
				"html",
				"cssls",
				"clangd",
				"gopls",
				"golangci_lint_ls",
				"ruff",
			})
			vim.api.nvim_create_autocmd("LspAttach", {
				callback = function(args)
					local client = vim.lsp.get_client_by_id(args.data.client_id)

					if client and client:supports_method("textDocument/completion") then
						vim.bo[args.buf].omnifunc = "v:lua.MiniCompletion.completefunc_lsp"
					end
				end,
			})
		end,
	},

	----------------------------------------------------------------------
	-- MASON
	----------------------------------------------------------------------

	{
		"mason-org/mason.nvim",

		cmd = "Mason",

		opts = {},
	},

	----------------------------------------------------------------------
	-- MASON TOOL INSTALLER
	----------------------------------------------------------------------

	{
		"WhoIsSethDaniel/mason-tool-installer.nvim",

		dependencies = {
			"mason-org/mason.nvim",
		},

		event = "VeryLazy",

		opts = {
			ensure_installed = {
				"gopls",
				"clangd",
				"lua-language-server",
				"html-lsp",
				"css-lsp",
			},

			auto_update = false,
			run_on_start = true,
			start_delay = 3000,
			debounce_hours = 5,
		},
	},

	----------------------------------------------------------------------
	-- CONFORM
	----------------------------------------------------------------------

	{
		"stevearc/conform.nvim",

		event = "BufWritePre",

		opts = {
			--------------------------------------------------------------------
			-- Formatters
			--------------------------------------------------------------------

			formatters_by_ft = {
				-- Lua
				lua = {
					"stylua",
				},

				-- Nix
				nix = {
					"nixfmt",
				},

				-- C / C++
				c = {
					"clang_format",
				},

				cpp = {
					"clang_format",
				},

				-- Go
				go = {
					"goimports",
					"gofumpt",
				},

				-- Python
				python = {
					"ruff_format",
				},

				-- Web
				html = {
					"prettier",
				},

				css = {
					"prettier",
				},

				scss = {
					"prettier",
				},

				javascript = {
					"prettier",
				},

				javascriptreact = {
					"prettier",
				},

				typescript = {
					"prettier",
				},

				typescriptreact = {
					"prettier",
				},

				-- Data / documentation
				json = {
					"prettier",
				},

				yaml = {
					"prettier",
				},

				markdown = {
					"prettier",
				},
			},

			--------------------------------------------------------------------
			-- Format on save
			--------------------------------------------------------------------

			format_on_save = {
				timeout_ms = 500,
				lsp_fallback = true,
			},
		},
	},

	----------------------------------------------------------------------
	-- MARKDOWN PREVIEW
	----------------------------------------------------------------------

	{
		"iamcco/markdown-preview.nvim",

		cmd = {
			"MarkdownPreviewToggle",
			"MarkdownPreview",
			"MarkdownPreviewStop",
		},

		build = "cd app && yarn install --force",

		init = function()
			vim.g.mkdp_filetypes = {
				"markdown",
			}

			vim.g.mkdp_browser = "zen"
		end,

		ft = {
			"markdown",
		},
	},

	----------------------------------------------------------------------
	-- SMEAR CURSOR
	----------------------------------------------------------------------

	{
		"sphamba/smear-cursor.nvim",

		event = "VeryLazy",

		opts = {
			smear_between_buffers = true,
			smear_between_neighbor_lines = true,
			scroll_buffer_space = true,
			legacy_computing_symbols_support = true,
			transparent_bg_fallback_color = "#1e222a",
			smear_insert_mode = true,
			time_interval = 10,
		},
	},

	---
	-- AUTOPAIRS
	---

	{
		"windwp/nvim-autopairs",

		event = "InsertEnter",

		opts = {},
	},

	---
	-- GIT SIGNS
	---

	{
		"lewis6991/gitsigns.nvim",

		event = {
			"BufReadPre",
			"BufNewFile",
		},

		opts = {},
	},

	---
	-- TREESITTER
	---

	{
		"nvim-treesitter/nvim-treesitter",

		branch = "main",

		lazy = false,

		build = ":TSUpdate",

		opts = {},

		config = function()
			require("nvim-treesitter").setup({
				install_dir = vim.fn.stdpath("data") .. "/site",
			})

			require("nvim-treesitter").install({
				"bash",
				"go",
				"c",
				"cpp",
				"elixir",
				"rust",
				"lua",
				"markdown",
				"markdown_inline",
				"python",
				"vim",
				"vimdoc",
				"query",
				"latex",
				"json",
				"yaml",
				"html",
				"css",
				"nix",
			})

			vim.api.nvim_create_autocmd("FileType", {
				callback = function()
					local ok = pcall(vim.treesitter.start)

					if not ok then
						return
					end
				end,
			})
		end,
	},

	---
	-- COLORIZER
	---

	{
		"catgoose/nvim-colorizer.lua",

		event = {
			"BufReadPost",
			"BufNewFile",
		},

		opts = {
			filetypes = {
				"*",
			},

			user_default_options = {
				RGB = true,
				RRGGBB = true,
				names = true,
				RRGGBBAA = true,
				AARRGGBB = true,
				css = true,
				css_fn = true,
				tailwind = false,
				mode = "background",
			},
		},
	},

	----------------------------------------------------------------------
	-- TABLINE
	----------------------------------------------------------------------

	{
		"nvim-mini/mini.tabline",

		version = "*",

		dependencies = {
			"nvim-tree/nvim-web-devicons",
		},

		event = "VeryLazy",

		config = function()
			require("mini.tabline").setup({
				show_icons = true,

				tabpage_section = "right",
			})
		end,
	},

	----------------------------------------------------------------------
	-- CURSOR WORD
	----------------------------------------------------------------------

	{
		"nvim-mini/mini.cursorword",

		version = "*",

		event = {
			"BufReadPost",
			"BufNewFile",
		},

		opts = {
			delay = 100,
		},

		config = function(_, opts)
			require("mini.cursorword").setup(opts)
		end,
	},

	----------------------------------------------------------------------
	-- LUALINE
	----------------------------------------------------------------------

	{
		"nvim-lualine/lualine.nvim",

		dependencies = {
			"nvim-tree/nvim-web-devicons",
		},

		event = "VeryLazy",

		opts = {
			options = {
				theme = "onedark",
				globalstatus = true,
				component_separators = {
					left = "│",
					right = "│",
				},
				section_separators = {
					left = "",
					right = "",
				},
			},
		},
	},

	----------------------------------------------------------------------
	-- COMMENT
	----------------------------------------------------------------------

	{
		"numToStr/Comment.nvim",

		event = "VeryLazy",

		opts = {
			-- Don't create Comment.nvim's default mappings.
			mappings = {
				basic = false,
				extra = false,
			},
		},

		config = function(_, opts)
			local comment = require("Comment.api")

			require("Comment").setup(opts)

			-- Normal: <leader>/ comments current line
			vim.keymap.set("n", "<leader>/", function()
				comment.toggle.linewise.current()
			end, {
				desc = "Toggle comment",
			})

			-- Visual: <leader>/ comments selection and exits Visual mode
			vim.keymap.set("x", "<leader>/", function()
				comment.toggle.linewise(vim.fn.visualmode())

				-- Exit Visual mode after commenting.
				vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "nx", false)
			end, {
				desc = "Toggle comment selection",
			})
		end,
	},

	----------------------------------------------------------------------
	-- ICONS
	----------------------------------------------------------------------

	{
		"nvim-mini/mini.icons",

		version = "*",

		lazy = true,

		config = function()
			require("mini.icons").setup()

			MiniIcons.tweak_lsp_kind()
		end,
	},

	----------------------------------------------------------------------
	-- SNIPPETS
	----------------------------------------------------------------------

	{
		"nvim-mini/mini.snippets",

		version = "*",

		event = "InsertEnter",

		config = function()
			require("mini.snippets").setup()
		end,
	},

	----------------------------------------------------------------------
	-- COMPLETION
	----------------------------------------------------------------------

	{
		"nvim-mini/mini.completion",

		version = "*",

		event = "InsertEnter",

		dependencies = {
			"nvim-mini/mini.icons",
			"nvim-mini/mini.snippets",
		},

		opts = {
			delay = {
				completion = 100,
				info = 100,
				signature = 50,
			},

			window = {
				info = {
					height = 25,
					width = 80,
					border = "rounded",
				},

				signature = {
					height = 25,
					width = 80,
					border = "rounded",
				},
			},

			lsp_completion = {
				source_func = "omnifunc",
				auto_setup = false,
			},

			fallback_action = "<C-n>",

			mappings = {
				force_twostep = "<C-Space>",
				force_fallback = "<A-Space>",
				scroll_down = "<C-f>",
				scroll_up = "<C-b>",
			},
		},

		config = function(_, opts)
			require("mini.completion").setup(opts)

			----------------------------------------------------------------------
			-- COMPLETION KEYMAPS
			----------------------------------------------------------------------

			-- Tab: select next completion item.
			vim.keymap.set("i", "<Tab>", function()
				if vim.fn.pumvisible() == 1 then
					return vim.keycode("<C-n>")
				end

				return vim.keycode("<Tab>")
			end, {
				expr = true,
				silent = true,
			})

			-- Down: next completion item.
			vim.keymap.set("i", "<Down>", function()
				if vim.fn.pumvisible() == 1 then
					return vim.keycode("<C-n>")
				end

				return vim.keycode("<Down>")
			end, {
				expr = true,
				silent = true,
			})

			-- Up: previous completion item.
			vim.keymap.set("i", "<Up>", function()
				if vim.fn.pumvisible() == 1 then
					return vim.keycode("<C-p>")
				end

				return vim.keycode("<Up>")
			end, {
				expr = true,
				silent = true,
			})

			-- Ctrl-j: next completion item.
			vim.keymap.set("i", "<C-j>", function()
				if vim.fn.pumvisible() == 1 then
					return vim.keycode("<C-n>")
				end

				return vim.keycode("<C-j>")
			end, {
				expr = true,
				silent = true,
			})

			-- Ctrl-k: previous completion item.
			vim.keymap.set("i", "<C-k>", function()
				if vim.fn.pumvisible() == 1 then
					return vim.keycode("<C-p>")
				end

				return vim.keycode("<C-k>")
			end, {
				expr = true,
				silent = true,
			})
		end,
	},

	----------------------------------------------------------------------
	-- FUZZY FINDER
	----------------------------------------------------------------------

	{
		"nvim-mini/mini.pick",

		version = "*",

		dependencies = {
			"nvim-mini/mini.fuzzy",
		},

		config = function()
			require("mini.fuzzy").setup()

			local MiniPick = require("mini.pick")

			MiniPick.setup({
				options = {
					use_cache = true,
				},

				window = {
					config = function()
						local height = math.floor(vim.o.lines * 0.35)
						local width = math.floor(vim.o.columns * 0.70)

						return {
							anchor = "NW",
							row = math.floor((vim.o.lines - height) / 2),
							col = math.floor((vim.o.columns - width) / 2),
							height = height,
							width = width,
							border = "rounded",
						}
					end,
				},
			})

			vim.ui.select = MiniPick.ui_select
		end,
	},
})

-- ============================================================================
-- KEYMAPS
-- ============================================================================

local map = vim.keymap.set

-- Save
map({ "n", "i", "v" }, "<C-s>", "<cmd>w<cr>")

-- Enter command mode
map("n", ";", ":", { desc = "CMD enter command mode" })

-- Substitute word under cursor
map("n", "<leader>s", ":%s/\\<<C-r><C-w>\\>/<C-r><C-w>/gI<left><left><left>", { desc = "Substitute word under cursor" })

map("n", "<Esc>", "<cmd>nohlsearch<cr>", {
	desc = "Clear search highlight",
})

----------------------------------------------------------------------
-- GITSIGNS KEYMAPS
----------------------------------------------------------------------

map("n", "<leader>gb", "<cmd>Gitsigns blame_line<cr>", {
	desc = "Git blame line",
})

map("n", "<leader>gd", "<cmd>Gitsigns diffthis<cr>", {
	desc = "Git diff",
})

map("n", "<leader>gp", "<cmd>Gitsigns preview_hunk<cr>", {
	desc = "Preview git hunk",
})

map("n", "<leader>gr", "<cmd>Gitsigns reset_hunk<cr>", {
	desc = "Reset git hunk",
})

map("n", "<leader>gs", "<cmd>Gitsigns stage_hunk<cr>", {
	desc = "Stage git hunk",
})

----------------------------------------------------------------------
-- NVIM-TREE KEYMAPS
----------------------------------------------------------------------

map("n", "<leader>e", "<cmd>NvimTreeToggle<cr>", {
	desc = "Toggle file explorer",
})

----------------------------------------------------------------------
-- FUZZY SEARCH
----------------------------------------------------------------------

-- Find files
map("n", "<leader>f", function()
	MiniPick.builtin.files()
end, {
	desc = "Find files",
})

-- Find word in files
map("n", "<leader>F", function()
	MiniPick.builtin.grep_live()
end, {
	desc = "Find word",
})

----------------------------------------------------------------------
-- LSP KEYMAPS
----------------------------------------------------------------------

map("n", "gd", vim.lsp.buf.definition, {
	desc = "Go to definition",
})

map("n", "gD", vim.lsp.buf.declaration, {
	desc = "Go to declaration",
})

map("n", "gr", vim.lsp.buf.references, {
	desc = "Find references",
})

map("n", "K", vim.lsp.buf.hover, {
	desc = "Hover documentation",
})

map("n", "<leader>rn", vim.lsp.buf.rename, {
	desc = "Rename symbol",
})

map("n", "<leader>E", function()
	vim.diagnostic.setloclist({
		open = true,
	})
end, {
	desc = "Show file diagnostics",
})
