-- ============================================================================
--                                                  |
--                                        _.---.  \ _ /
--                                       (_._ ) )--;_) =-
--                                         '---'.__,' \
--                                                  |
--                        ':.
--                          []_____                p
--                  ~^~ ~^~/\      \~ ~^~ ~^~ -^~^~|\ ~^-~^~-
--                  ^  ___/  \__/\__\__         ~ /| \
--                   ~/\____ |''''''|__\  ~      /_|__\  ^
--                  .-||'''| |''||''|'| ._    ^   ~~~~
--                    ``"""`"`"))""`""`   '-.              ~
--                                      __.-'      ^
-------------------------------------------------------------------------------
-- Ascii Art based on:
-- https://www.asciiart.eu/art/4d138238c472ae79
-- and
-- https://www.asciiart.eu/art/60635330afd894c7
-------------------------------------------------------------------------------
--  A Neovim configuration by gabrielzschmitz
--  Managed by Home Manager / NixOS
-- ============================================================================

-- ============================================================================
-- PLUGINS ON THE CONFIG
-- ============================================================================
--
-- MANAGER
--   vim.pack (native)
--
-- THEME
--   navarasu/onedark.nvim
--
-- DASHBOARD
--   nvim-mini/mini.starter
--
-- FILE EXPLORER
--   luukvbaal/nnn.nvim
--
-- LSP
--   neovim/nvim-lspconfig
--
-- FORMATTING
--   stevearc/conform.nvim
--
-- MARKDOWN
--   iamcco/markdown-preview.nvim
--
-- VISUAL EFFECTS
--   sphamba/smear-cursor.nvim
--
-- EDITING
--   windwp/nvim-autopairs
--   nvim-treesitter/nvim-treesitter
--   catgoose/nvim-colorizer.lua
--
-- GIT
--   lewis6991/gitsigns.nvim
--
-- UI
--   nvim-mini/mini.tabline
--   nvim-lualine/lualine.nvim
--   nvim-mini/mini.icons
--   nvim-mini/mini.cursorword
--
-- COMPLETION
--   nvim-mini/mini.completion
--   nvim-mini/mini.snippets
--
-- FUZZY FINDER
--   nvim-mini/mini.pick
--   nvim-mini/mini.fuzzy
--
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

vim.api.nvim_create_autocmd("FileType", {
	callback = function()
		vim.opt_local.expandtab = true
		vim.opt_local.shiftwidth = 2
		vim.opt_local.tabstop = 2
		vim.opt_local.softtabstop = 2
	end,
})

vim.opt.smartindent = true
vim.opt.wrap = true
vim.opt.showmode = false

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

--  vim.g.loaded_netrw = 1
--  vim.g.loaded_netrwPlugin = 1

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
-- VIM.PACK
-- ============================================================================

local gh = function(repo)
	return "https://github.com/" .. repo
end

-- mini.nvim plugins use semver release tags.
local mini_version = vim.version.range("*")

-- The Nix-managed lockfile is a read-only symlink, but vim.pack writes it
-- during add/update/del. Replace the symlink with a writable copy seeded from
-- the Nix store before vim.pack touches it.
local function make_lockfile_writable()
	local path = vim.fs.joinpath(vim.fn.stdpath("config"), "nvim-pack-lock.json")

	if vim.fn.getftype(path) ~= "link" then
		return
	end

	local target = vim.fn.resolve(path)

	if vim.fn.filereadable(target) == 0 then
		return
	end

	local lines = vim.fn.readfile(target)

	vim.fn.delete(path)
	vim.fn.writefile(lines, path)
end

make_lockfile_writable()

-- Build steps run after installation/update, outside the setup calls.
vim.api.nvim_create_autocmd("PackChanged", {
	callback = function(ev)
		local name = ev.data.spec.name

		if name == "markdown-preview.nvim" and (ev.data.kind == "install" or ev.data.kind == "update") then
			vim.system({ "npx", "--yes", "yarn", "install", "--force" }, {
				cwd = ev.data.path .. "/app",
			}):wait()
		end
	end,
})

-- vim.pack has no event/ft/cmd lazy loading, so plugins are loaded during
-- startup. `load = true` sources each plugin's plugin/ and ftdetect/ files
-- immediately instead of waiting until after init.lua.
--
-- All plugins are declared in this table and configured below.
local plugins = {
	-- THEME
	{ src = gh("navarasu/onedark.nvim") },

	-- DASHBOARD
	{ src = gh("nvim-mini/mini.starter"), version = mini_version },

	-- FILE EXPLORER
	{ src = gh("luukvbaal/nnn.nvim") },

	-- COMPLETION
	{ src = gh("nvim-mini/mini.icons"), version = mini_version },
	{ src = gh("nvim-mini/mini.snippets"), version = mini_version },
	{ src = gh("nvim-mini/mini.completion"), version = mini_version },

	-- LSP
	{ src = gh("neovim/nvim-lspconfig") },

	-- FORMATTING
	{ src = gh("stevearc/conform.nvim") },

	-- MARKDOWN
	{ src = gh("iamcco/markdown-preview.nvim") },

	-- VISUAL EFFECTS
	{ src = gh("sphamba/smear-cursor.nvim") },

	-- EDITING
	{ src = gh("windwp/nvim-autopairs") },
	{ src = gh("nvim-treesitter/nvim-treesitter"), version = "main" },
	{ src = gh("catgoose/nvim-colorizer.lua") },

	-- GIT
	{ src = gh("lewis6991/gitsigns.nvim") },

	-- UI
	{ src = gh("nvim-mini/mini.tabline"), version = mini_version },
	{ src = gh("nvim-mini/mini.cursorword"), version = mini_version },
	{ src = gh("nvim-lualine/lualine.nvim") },

	-- FUZZY FINDER
	{ src = gh("nvim-mini/mini.fuzzy"), version = mini_version },
	{ src = gh("nvim-mini/mini.pick"), version = mini_version },
}

vim.pack.add(plugins, {
	confirm = false,
	load = true,
})

-- ============================================================================
-- PLUGIN CONFIG
-- ============================================================================

----------------------------------------------------------------------
-- THEME
----------------------------------------------------------------------

require("onedark").setup({
	style = "dark",
	transparent = true,
	lualine = {
		transparent = true,
	},
})

require("onedark").load()

----------------------------------------------------------------------
-- DASHBOARD
----------------------------------------------------------------------

do
	local starter = require("mini.starter")

	----------------------------------------------------------------
	-- ASCII ART COLORS (16-COLOR TERMINAL PALETTE)
	----------------------------------------------------------------

	local header_ns = vim.api.nvim_create_namespace("MiniStarterHeaderColors")

	local header_palette = {
		[0] = "StarterHeaderColor0",
		[1] = "StarterHeaderColor1",
		[2] = "StarterHeaderColor2",
		[3] = "StarterHeaderColor3",
		[4] = "StarterHeaderColor4",
		[5] = "StarterHeaderColor5",
		[6] = "StarterHeaderColor6",
		[7] = "StarterHeaderColor7",
		[8] = "StarterHeaderColor8",
		[9] = "StarterHeaderColor9",
		[10] = "StarterHeaderColor10",
		[11] = "StarterHeaderColor11",
		[12] = "StarterHeaderColor12",
		[13] = "StarterHeaderColor13",
		[14] = "StarterHeaderColor14",
		[15] = "StarterHeaderColor15",
	}

	local terminal_colors = {
		"#181b21", -- 0: Black
		"#be5046", -- 1: Red
		"#81ae5f", -- 2: Green
		"#d19a66", -- 3: Yellow
		"#4889be", -- 4: Blue
		"#7560d3", -- 5: Magenta
		"#49919a", -- 6: Cyan
		"#abb2bf", -- 7: Grey
		"#5c6370", -- 8: Bright Black
		"#e06c75", -- 9: Bright Red
		"#98c379", -- 10: Bright Green
		"#e5c07b", -- 11: Bright Yellow
		"#61afef", -- 12: Bright Blue
		"#8677cf", -- 13: Bright Magenta
		"#56b6c2", -- 14: Bright Cyan
		"#b8bfe5", -- 15: Bright White
	}

	for i, color in ipairs(terminal_colors) do
		vim.api.nvim_set_hl(0, "StarterHeaderColor" .. (i - 1), {
			fg = color,
			bold = true,
		})
	end

	----------------------------------------------------------------
	-- INLINE COLOR PARSER
	----------------------------------------------------------------

	local function parse_header(source)
		local lines = {}
		local highlights = {}

		local current_color = nil

		for row, line in
			ipairs(vim.split(source, "\n", {
				plain = true,
			}))
		do
			local output = {}
			local byte_col = 0
			local pos = 1

			while pos <= #line do
				-- Recognize color directives: \c1, \c2, etc.
				local color, next_pos = line:match("^\\c(%d+)()", pos)

				if color then
					current_color = tonumber(color)
					pos = next_pos
				else
					local char = vim.fn.strcharpart(line:sub(pos), 0, 1)

					local char_bytes = #char

					if current_color and header_palette[current_color] then
						table.insert(highlights, {
							row = row - 1,
							start_col = byte_col,
							end_col = byte_col + char_bytes,
							group = header_palette[current_color],
						})
					end

					table.insert(output, char)

					byte_col = byte_col + char_bytes
					pos = pos + char_bytes
				end
			end

			table.insert(lines, table.concat(output))
		end

		return table.concat(lines, "\n"), highlights
	end

	----------------------------------------------------------------
	-- HEADER
	----------------------------------------------------------------

	local raw_header = [[
                                \c11|
                      \c7_.---.  \c11\ _ /
                     \c7(_._ ) )--;\c11_) =-
                       \c7'---'.__,'\c11 \
                                \c11|
      \c7':.
        \c1[]_____                \c11p
\c4~^~ ~^~\c1/\      \\c4~ ~^~ ~^~ -^~^~\c3|\c7\\c4 ~^-~^~-
\c4^  \c1___/  \__/\__\__\c4         ~ \c7/\c3|\c7 \\c4
\c4 ~\c1/\____ \c11|''''''|\c1__\\c4  ~      \c7/_\c3|\c7__\\c4  ^
\c2.-\c11||'''| |''||''|'| \c2._\c4    ^   \c3~~~~\c4
  \c10``"""`"`"\c3))\c10""`""`   \c2'-.\c4              ~
                    \c2__.-'\c4      ^
]]

	local parsed_header, header_highlights = parse_header(raw_header)

	----------------------------------------------------------------
	-- APPLY HEADER COLORS
	----------------------------------------------------------------

	local function apply_header_colors()
		local buf = vim.api.nvim_get_current_buf()

		if not vim.api.nvim_buf_is_valid(buf) or vim.bo[buf].filetype ~= "ministarter" then
			return
		end

		vim.api.nvim_buf_clear_namespace(buf, header_ns, 0, -1)

		local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)

		-- Locate the first rendered header line.
		local first_header = nil

		for row, line in ipairs(lines) do
			if line:find(vim.split(parsed_header, "\n", { plain = true })[1], 1, true) then
				first_header = row - 1
				break
			end
		end

		if first_header == nil then
			return
		end

		-- Calculate horizontal offset from the rendered header.
		local first_line = vim.split(parsed_header, "\n", { plain = true })[1]

		local rendered_first_line = lines[first_header + 1]
		local header_offset = rendered_first_line:find(first_line, 1, true)

		if not header_offset then
			return
		end

		header_offset = header_offset - 1

		for _, hl in ipairs(header_highlights) do
			local row = first_header + hl.row
			local line = lines[row + 1]

			if line then
				vim.api.nvim_buf_set_extmark(buf, header_ns, row, header_offset + hl.start_col, {
					end_col = header_offset + hl.end_col,
					hl_group = hl.group,
					priority = 200,
				})
			end
		end
	end

	----------------------------------------------------------------
	-- STARTER SETUP
	----------------------------------------------------------------

	starter.setup({
		autoopen = true,
		evaluate_single = false,

		header = parsed_header,

		items = {
			starter.sections.builtin_actions(),
			starter.sections.recent_files(5, true),
		},

		footer = ("Neovim Config by gabrielzschmitz (v%s)"):format(
			vim.version().major .. "." .. vim.version().minor .. "." .. vim.version().patch
		),

		content_hooks = {
			starter.gen_hook.adding_bullet(),

			starter.gen_hook.indexing("all", {
				"Builtin actions",
				"Recent files",
			}),

			-- Vertical centering.
			starter.gen_hook.aligning("left", "center"),

			-- Horizontal centering and shared menu alignment.
			function(content, buf_id)
				local win_id = vim.fn.bufwinid(buf_id)

				if win_id < 0 then
					return content
				end

				local width = vim.api.nvim_win_get_width(win_id)

				local widths = {
					header = 0,
					menu = 0,
					footer = 0,
				}

				-- Calculate maximum width of each block.
				for _, line in ipairs(content) do
					local line_type
					local line_text = ""

					for _, unit in ipairs(line) do
						line_text = line_text .. unit.string

						if unit.type == "header" then
							line_type = "header"
						elseif unit.type == "item" or unit.type == "section" then
							line_type = "menu"
						elseif unit.type == "footer" then
							line_type = "footer"
						end
					end

					if line_type then
						widths[line_type] = math.max(widths[line_type], vim.fn.strdisplaywidth(line_text))
					end
				end

				-- Calculate horizontal offsets.
				local padding = {}

				for block, block_width in pairs(widths) do
					padding[block] = math.max(0, math.floor((width - block_width) / 2))
				end

				-- Apply horizontal offsets.
				for _, line in ipairs(content) do
					local line_type

					for _, unit in ipairs(line) do
						if unit.type == "header" then
							line_type = "header"
							break
						elseif unit.type == "item" or unit.type == "section" then
							line_type = "menu"
							break
						elseif unit.type == "footer" then
							line_type = "footer"
							break
						end
					end

					if line_type and padding[line_type] > 0 then
						table.insert(line, 1, {
							type = "empty",
							string = string.rep(" ", padding[line_type]),
						})
					end
				end

				return content
			end,
		},
	})

	----------------------------------------------------------------
	-- GENERAL COLORS
	----------------------------------------------------------------

	vim.api.nvim_set_hl(0, "MiniStarterHeader", {
		fg = "#56b6c2",
		bold = true,
	})

	vim.api.nvim_set_hl(0, "MiniStarterFooter", {
		fg = "#5c6370",
		italic = true,
	})

	vim.api.nvim_set_hl(0, "MiniStarterSection", {
		fg = "#49919a",
		bold = true,
	})

	vim.api.nvim_set_hl(0, "MiniStarterItem", {
		fg = "#abb2bf",
	})

	vim.api.nvim_set_hl(0, "MiniStarterItemPrefix", {
		fg = "#61afef",
		bold = true,
	})

	vim.api.nvim_set_hl(0, "MiniStarterCurrent", {
		fg = "#abb2bf",
		bold = true,
	})

	vim.api.nvim_set_hl(0, "MiniStarterQuery", {
		fg = "#e5c07b",
		bold = true,
	})

	----------------------------------------------------------------
	-- AUTOCMDS
	----------------------------------------------------------------

	local group = vim.api.nvim_create_augroup("MiniStarterHeaderColors", { clear = true })

	vim.api.nvim_create_autocmd("User", {
		group = group,
		pattern = "MiniStarterOpened",
		callback = function()
			vim.schedule(apply_header_colors)
		end,
	})

	vim.api.nvim_create_autocmd("VimResized", {
		group = group,
		callback = function()
			vim.schedule(apply_header_colors)
		end,
	})
end

----------------------------------------------------------------------
-- FILE EXPLORER
----------------------------------------------------------------------

do
	local function open_file(files)
		if files and files[1] and vim.fn.isdirectory(files[1]) == 0 then
			vim.cmd("edit " .. vim.fn.fnameescape(files[1]))
		end
	end

	require("nnn").setup({
		picker = {
			cmd = "nnn",
			session = "shared",
			tabs = false,
			fullscreen = false,

			style = {
				width = 0.9,
				height = 0.8,
				border = "double",
			},
		},

		mappings = {
			{ "e", open_file },
			{ "l", open_file },
			{ "<Right>", open_file },
		},

		offset = true,
		replace_netrw = "picker",
	})

	-- COLORS
	vim.api.nvim_set_hl(0, "NnnNormal", {
		fg = "#abb2bf",
		bg = "#14171c",
	})

	vim.api.nvim_set_hl(0, "NnnNormalNC", {
		fg = "#5c6370",
		bg = "#1e222a",
	})

	vim.api.nvim_set_hl(0, "NnnBorder", {
		fg = "#61afef",
		bg = "#14171c",
	})
end

----------------------------------------------------------------------
-- ICONS
----------------------------------------------------------------------

do
	require("mini.icons").setup()

	MiniIcons.tweak_lsp_kind()
end

----------------------------------------------------------------------
-- SNIPPETS
----------------------------------------------------------------------

require("mini.snippets").setup()

----------------------------------------------------------------------
-- COMPLETION
----------------------------------------------------------------------

do
	require("mini.completion").setup({
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
	})

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
end

----------------------------------------------------------------------
-- LSP
----------------------------------------------------------------------

do
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

				options = {
					nixos = {
						expr = string.format(
							"(builtins.getFlake (toString ./.)).nixosConfigurations.%s.options",
							vim.fn.hostname()
						),
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
			"--fallback-style=file:" .. vim.fn.stdpath("config") .. "/.clang-format",
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
	-- Bash / Shell
	--------------------------------------------------------------------

	vim.lsp.config("bashls", {
		capabilities = capabilities,

		filetypes = {
			"sh",
			"bash",
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
		"bashls",
	})
	vim.api.nvim_create_autocmd("LspAttach", {
		callback = function(args)
			local client = vim.lsp.get_client_by_id(args.data.client_id)

			if client and client:supports_method("textDocument/completion") then
				vim.bo[args.buf].omnifunc = "v:lua.MiniCompletion.completefunc_lsp"
			end
		end,
	})
	vim.api.nvim_create_autocmd("FileType", {
		pattern = { "bash", "sh" },
		callback = function(args)
			vim.bo[args.buf].textwidth = 80
			vim.bo[args.buf].formatoptions = vim.bo[args.buf].formatoptions .. "ctq"
		end,
	})
end

----------------------------------------------------------------------
-- CONFORM
----------------------------------------------------------------------

require("conform").setup({
	--------------------------------------------------------------------
	-- Formatters
	--------------------------------------------------------------------

	formatters_by_ft = {
		-- Bash / Shell
		bash = {
			"shfmt",
		},

		sh = {
			"shfmt",
		},

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

	formatters = {
		shfmt = {
			prepend_args = { "-i", "2", "-ci", "-bn", "-sr" },
		},

		clang_format = {
			prepend_args = { "-style=file:" .. vim.fn.stdpath("config") .. "/.clang-format" },
		},
	},

	--------------------------------------------------------------------
	-- Format on save
	--------------------------------------------------------------------

	format_on_save = function(bufnr)
		local filetype = vim.bo[bufnr].filetype

		if filetype == "bash" or filetype == "sh" then
			local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

			for i = #lines, 1, -1 do
				local prefix, comment = lines[i]:match("^(%s*#%s?)(.*)$")

				if prefix and #lines[i] > 80 then
					local width = 80 - #prefix
					local wrapped = {}
					local current = ""

					for word in comment:gmatch("%S+") do
						if current == "" then
							current = word
						elseif #current + #word + 1 <= width then
							current = current .. " " .. word
						else
							wrapped[#wrapped + 1] = prefix .. current
							current = word
						end
					end

					if current ~= "" then
						wrapped[#wrapped + 1] = prefix .. current
					end

					vim.api.nvim_buf_set_lines(bufnr, i - 1, i, false, wrapped)
				end
			end
		end

		return {
			timeout_ms = 500,
			lsp_fallback = true,
		}
	end,
})

----------------------------------------------------------------------
-- MARKDOWN PREVIEW
----------------------------------------------------------------------

vim.g.mkdp_filetypes = { "markdown" }
vim.g.mkdp_echo_preview_url = 1

vim.g.mkdp_browserfunc = "OpenMarkdownPreview"

vim.cmd([[
	function! OpenMarkdownPreview(url)
		call jobstart(["xdg-open", a:url], {"detach": v:true})
	endfunction
]])

----------------------------------------------------------------------
-- SMEAR CURSOR
----------------------------------------------------------------------

require("smear_cursor").setup({
	smear_between_buffers = true,
	smear_between_neighbor_lines = true,
	scroll_buffer_space = true,
	legacy_computing_symbols_support = true,
	transparent_bg_fallback_color = "#1e222a",
	smear_insert_mode = true,
	time_interval = 10,
})

---
-- AUTOPAIRS
---

require("nvim-autopairs").setup({})

---
-- GIT SIGNS
---

require("gitsigns").setup({})

---
-- TREESITTER
---

do
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
end

---
-- COLORIZER
---

require("colorizer").setup({
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
})

----------------------------------------------------------------------
-- TABLINE
----------------------------------------------------------------------

do
	require("mini.tabline").setup({
		show_icons = true,

		tabpage_section = "right",
	})

	-- COLORS

	-- Selected buffer: bold white
	vim.api.nvim_set_hl(0, "MiniTablineCurrent", {
		fg = "#b8bfe5",
		bg = "#5c6370",
		bold = true,
	})

	-- Visible inactive buffers: light grey
	vim.api.nvim_set_hl(0, "MiniTablineVisible", {
		fg = "#abb2bf",
		bg = "#393f4a",
	})

	-- Hidden buffers: dim grey
	vim.api.nvim_set_hl(0, "MiniTablineHidden", {
		fg = "#5c6370",
		bg = "#393f4a",
	})

	-- Modified buffers: preserve the same color hierarchy
	vim.api.nvim_set_hl(0, "MiniTablineModifiedCurrent", {
		fg = "#b8bfe5",
		bg = "#393f4a",
		bold = true,
		underline = true,
	})

	vim.api.nvim_set_hl(0, "MiniTablineModifiedVisible", {
		fg = "#abb2bf",
		bg = "#393f4a",
		underline = true,
	})

	vim.api.nvim_set_hl(0, "MiniTablineModifiedHidden", {
		fg = "#5c6370",
		bg = "#393f4a",
		underline = true,
	})
end

----------------------------------------------------------------------
-- CURSOR WORD
----------------------------------------------------------------------

require("mini.cursorword").setup({
	delay = 100,
})

----------------------------------------------------------------------
-- LUALINE
----------------------------------------------------------------------

require("lualine").setup({
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
})

----------------------------------------------------------------------
-- FUZZY FINDER
----------------------------------------------------------------------

require("mini.fuzzy").setup()

----------------------------------------------------------------------
-- PICK
----------------------------------------------------------------------

do
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
end

-- ============================================================================
-- KEYMAPS
-- ============================================================================

local map = vim.keymap.set

map("n", "<leader>pu", update_plugins, {
	desc = "Update plugins",
})

map("n", "<leader>pr", remove_plugin, {
	desc = "Remove plugin from disk",
})

-- Save
map({ "n", "i", "v" }, "<C-s>", "<cmd>w<cr>")

-- Enter command mode
map("n", ";", ":", { desc = "CMD enter command mode" })

-- Substitute word under cursor
map("n", "<leader>s", ":%s/\\<<C-r><C-w>\\>/<C-r><C-w>/gI<left><left><left>", { desc = "Substitute word under cursor" })

map("n", "<Esc>", "<cmd>nohlsearch<cr>", {
	desc = "Clear search highlight",
})

-- Move selected lines
map("v", "J", ":m '>+1<CR>gv=gv")
map("v", "K", ":m '<-2<CR>gv=gv")
map("v", "H", "<gv")
map("v", "L", ">gv")

----------------------------------------------------------------------
-- PLUGIN MANAGEMENT
----------------------------------------------------------------------

local function update_plugins()
	make_lockfile_writable()

	vim.pack.update()
end

local function remove_plugin()
	make_lockfile_writable()

	local plugins = vim.pack.get()

	if #plugins == 0 then
		vim.notify("No vim.pack plugins found", vim.log.levels.WARN)
		return
	end

	local choices = {}

	for _, plugin in ipairs(plugins) do
		table.insert(choices, {
			name = plugin.spec.name,
			active = plugin.active,
			label = plugin.spec.name .. (plugin.active and " [active]" or ""),
		})
	end

	vim.ui.select(choices, {
		prompt = "Remove plugin from disk",
		format_item = function(item)
			return item.label
		end,
	}, function(choice)
		if not choice then
			return
		end

		if choice.active then
			local answer = vim.fn.confirm(
				("'%s' is active and still declared in init.lua. It will reinstall on next start. Remove anyway?"):format(
					choice.name
				),
				"&Yes\n&No",
				2
			)

			if answer ~= 1 then
				return
			end
		end

		local ok, err = pcall(vim.pack.del, { choice.name }, {
			force = choice.active,
		})

		if not ok then
			vim.notify("Failed to remove " .. choice.name .. ": " .. tostring(err), vim.log.levels.ERROR)
			return
		end

		vim.notify("Removed " .. choice.name .. " from disk")
	end)
end

----------------------------------------------------------------------
-- COMMENT
----------------------------------------------------------------------

local function toggle_comment(start_line, end_line)
	local commentstring = vim.bo.commentstring

	if commentstring == "" then
		vim.notify("No commentstring defined for this filetype", vim.log.levels.WARN)
		return
	end

	local left, right = commentstring:match("^(.-)%%s(.-)$")

	if not left then
		vim.notify("Invalid commentstring: " .. commentstring, vim.log.levels.WARN)
		return
	end

	local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)

	-- Determine whether all non-empty lines are already commented.
	local all_commented = true

	for _, line in ipairs(lines) do
		if line:match("%S") then
			local trimmed = line:match("^%s*(.*)$")

			if trimmed:sub(1, #left) ~= left then
				all_commented = false
				break
			end
		end
	end

	for i, line in ipairs(lines) do
		if line:match("%S") then
			local indent = line:match("^%s*")
			local content = line:sub(#indent + 1)

			if all_commented then
				content = content:gsub("^" .. vim.pesc(left), "", 1)
				content = content:gsub("^" .. vim.pesc(right), "", 1)
				content = content:gsub("^ ", "", 1)
			else
				content = left .. " " .. content .. right
			end

			lines[i] = indent .. content
		end
	end

	vim.api.nvim_buf_set_lines(0, start_line - 1, end_line, false, lines)
end

-- Normal: <leader>/ comments current line.
vim.keymap.set("n", "<leader>/", function()
	local line = vim.fn.line(".")
	toggle_comment(line, line)
end, {
	desc = "Toggle comment",
})

-- Visual: <leader>/ comments selected lines.
vim.keymap.set("x", "<leader>/", function()
	local start_line = vim.fn.line("v")
	local end_line = vim.fn.line(".")

	if start_line > end_line then
		start_line, end_line = end_line, start_line
	end

	toggle_comment(start_line, end_line)

	vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "nx", false)
end, {
	desc = "Toggle comment selection",
})

----------------------------------------------------------------------
-- DASHBOARD
----------------------------------------------------------------------

map("n", "<leader>h", "<cmd>lua MiniStarter.open()<cr>", {
	desc = "Open dashboard",
})

----------------------------------------------------------------------
-- GITSIGNS
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
-- NNN
----------------------------------------------------------------------

map("n", "<leader>e", "<cmd>NnnPicker<cr>", {
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
