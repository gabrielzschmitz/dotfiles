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

-- Leader keys for custom keybindings
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Show absolute line number on the current line and relative numbers elsewhere
vim.opt.number = true
vim.opt.relativenumber = true

-- Use spaces instead of tabs; set indentation width to 2 spaces
vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.softtabstop = 2

-- Apply indentation settings locally to every buffer
vim.api.nvim_create_autocmd("Filetype", {
	callback = function()
		vim.opt_local.expandtab = true
		vim.opt_local.shiftwidth = 2
		vim.opt_local.tabstop = 2
		vim.opt_local.softtabstop = 2
	end,
})

-- Automatically indent new lines based on the previous line
vim.opt.smartindent = true

-- Wrap long lines instead of extending them beyond the window
vim.opt.wrap = true

-- Hide the mode indicator (e.g. INSERT, NORMAL), usually shown in the
-- statusline
vim.opt.showmode = false

-- Enable 24-bit RGB colors in the terminal
vim.opt.termguicolors = true

-- Ignore case when searching, unless the search contains uppercase letters
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Highlight the line where the cursor is located
vim.opt.cursorline = true

-- Always reserve space for signs (diagnostics, Git changes, etc.)
vim.opt.signcolumn = "yes"

-- Open vertical splits to the right and horizontal splits below
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Keep a minimum of 8 visible lines and columns around the cursor when
-- scrolling
vim.opt.scrolloff = 8
vim.opt.sidescrolloff = 8

-- Time (in milliseconds) before triggering CursorHold and other idle events
vim.opt.updatetime = 250

-- Time (in milliseconds) to wait for a mapped key sequence to complete
vim.opt.timeoutlen = 500

-- Time (in milliseconds) to wait for terminal key codes to complete
vim.opt.ttimeoutlen = 10

-- Enable mouse support in all modes
vim.opt.mouse = "a"

-- Use the system clipboard for all yank, delete, change, and put operations
vim.opt.clipboard = "unnamedplus"

-- Configure the insert-mode completion menu
vim.opt.completeopt = {
	"menu", -- Show the completion menu
	"menuone", -- Show the menu even when there is only one match
	"noselect", -- Do not automatically select the first match
}

-- Disable auxiliary files
vim.opt.swapfile = false -- Disable swap files used for crash recovery
-- Disable backup files created before overwriting a file
vim.opt.backup = false
vim.opt.writebackup = false -- Disable temporary backups during file writes
vim.opt.undofile = false -- Disable persistent undo history between sessions

-- Disable built-in netrw file explorer
-- vim.g.loaded_netrw = 1
-- vim.g.loaded_netrwPlugin = 1

-- ============================================================================
-- DIAGNOSTICS
-- ============================================================================

vim.diagnostic.config({
	virtual_text = true, -- Display diagnostic messages inline
	signs = true, -- Show diagnostic signs in the sign column
	underline = true, -- Underline code with diagnostics
	-- Update diagnostics only after leaving insert mode
	update_in_insert = false,
	-- Sort diagnostics by severity (errors before warnings)
	severity_sort = true,

	float = {
		-- Use a single-line border for diagnostic floating windows
		border = "single",
		-- Show the diagnostic source when multiple sources are available
		source = "if_many",
	},
})

-- ============================================================================
-- VIM.PACK
-- ============================================================================

-- Build a GitHub repository URL from its owner/repository name
local gh = function(repo)
	return "https://github.com/" .. repo
end

-- Use the latest available semver release for mini.nvim plugins
local mini_version = vim.version.range("*")

-- Make the Nix-managed lockfile writable before vim.pack modifies it
-- The original is a read-only symlink pointing into the Nix store
local function make_lockfile_writable()
	local path = vim.fs.joinpath(vim.fn.stdpath("config"), "nvim-pack-lock.json")

	-- Only replace the file when it is a symlink
	if vim.fn.getftype(path) ~= "link" then
		return
	end

	-- Resolve the symlink to its actual target
	local target = vim.fn.resolve(path)

	-- Skip replacement if the target does not exist or is unreadable
	if vim.fn.filereadable(target) == 0 then
		return
	end

	-- Copy the lockfile contents into a regular, writable file
	local lines = vim.fn.readfile(target)

	vim.fn.delete(path)
	vim.fn.writefile(lines, path)
end

make_lockfile_writable()

-- Run plugin-specific build steps after installation or update
-- These commands execute outside the vim.pack setup process
vim.api.nvim_create_autocmd("PackChanged", {
	callback = function(ev)
		local name = ev.data.spec.name

		-- Install Markdown Preview dependencies when the plugin changes
		if name == "markdown-preview.nvim" and (ev.data.kind == "install" or ev.data.kind == "update") then
			vim.system({ "npx", "--yes", "yarn", "install", "--force" }, {
				cwd = ev.data.path .. "/app",
			}):wait()
		end
	end,
})

-- Declare all plugins in a single table, grouped by functionality.
-- vim.pack does not support lazy loading by event, filetype, or command,
-- so plugins are loaded during startup.
-- `load = true` immediately sources each plugin's plugin/ and ftdetect/ files.
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

-- Install or update declared plugins without asking for confirmation
-- Load plugin runtime files immediately after adding them
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

-- Configure the OneDark colorscheme
require("onedark").setup({
	style = "dark", -- Use the dark color palette
	-- Use the terminal background instead of a solid background
	transparent = true,
	lualine = {
		transparent = true, -- Make the Lualine statusline background transparent
	},
})

-- Apply the configured colorscheme
require("onedark").load()

----------------------------------------------------------------------
-- DASHBOARD
----------------------------------------------------------------------

do
	local starter = require("mini.starter")

	----------------------------------------------------------------------
	-- ASCII ART COLORS (16-COLOR TERMINAL PALETTE)
	----------------------------------------------------------------------

	-- Namespace used to manage and clear custom header highlights independently
	local header_ns = vim.api.nvim_create_namespace("MiniStarterHeaderColors")

	-- Map inline color indexes to their corresponding highlight groups
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

	-- OneDark-inspired colors mapped to the standard 16-color terminal palette
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

	-- Register a highlight group for each terminal color
	for i, color in ipairs(terminal_colors) do
		vim.api.nvim_set_hl(0, "StarterHeaderColor" .. (i - 1), {
			fg = color,
			bold = true,
		})
	end

	----------------------------------------------------------------------
	-- INLINE COLOR PARSER
	----------------------------------------------------------------------

	-- Convert inline color directives into plain text and highlight metadata
	-- Color directives use the format \cN, where N is a palette index
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
				-- Recognize color directives and update the active color
				local color, next_pos = line:match("^\\c(%d+)()", pos)

				if color then
					current_color = tonumber(color)
					pos = next_pos
				else
					-- Extract one UTF-8 character and calculate its byte length
					local char = vim.fn.strcharpart(line:sub(pos), 0, 1)

					local char_bytes = #char

					-- Record highlight boundaries using byte-based columns
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

	----------------------------------------------------------------------
	-- HEADER
	----------------------------------------------------------------------

	-- ASCII artwork with inline color directives (\c0 through \c15)
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

	-- Separate the rendered header text from its highlight metadata
	local parsed_header, header_highlights = parse_header(raw_header)

	----------------------------------------------------------------------
	-- APPLY HEADER COLORS
	----------------------------------------------------------------------

	-- Apply the parsed color metadata to the rendered dashboard buffer
	local function apply_header_colors()
		local buf = vim.api.nvim_get_current_buf()

		-- Only operate on valid MiniStarter buffers
		if not vim.api.nvim_buf_is_valid(buf) or vim.bo[buf].filetype ~= "ministarter" then
			return
		end

		-- Remove previous highlights before applying updated positions
		vim.api.nvim_buf_clear_namespace(buf, header_ns, 0, -1)

		local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)

		-- Locate the first rendered header line to determine its vertical offset
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

		-- Determine the horizontal offset introduced by MiniStarter alignment
		local first_line = vim.split(parsed_header, "\n", { plain = true })[1]

		local rendered_first_line = lines[first_header + 1]
		local header_offset = rendered_first_line:find(first_line, 1, true)

		if not header_offset then
			return
		end

		header_offset = header_offset - 1

		-- Restore each character's original color using extmarks
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

	----------------------------------------------------------------------
	-- STARTER SETUP
	----------------------------------------------------------------------

	starter.setup({
		autoopen = true, -- Open the dashboard automatically when Neovim starts
		-- Keep single-item sections from executing automatically
		evaluate_single = false,

		header = parsed_header,

		-- Dashboard sections and their contents
		items = {
			starter.sections.builtin_actions(),
			starter.sections.recent_files(5, true),
		},

		-- Display Neovim version in the dashboard footer
		footer = ("Neovim Config by gabrielzschmitz (v%s)"):format(
			vim.version().major .. "." .. vim.version().minor .. "." .. vim.version().patch
		),

		-- Transform and align dashboard content before rendering
		content_hooks = {
			-- Add bullet prefixes to menu entries
			starter.gen_hook.adding_bullet(),

			-- Assign indexes to menu entries and section titles
			starter.gen_hook.indexing("all", {
				"Builtin actions",
				"Recent files",
			}),

			-- Center content vertically while keeping it left-aligned
			starter.gen_hook.aligning("left", "center"),

			-- Calculate individual block widths and center them horizontally
			-- Header, menu, and footer are aligned independently
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

				-- Calculate maximum display width for each content block
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

				-- Calculate left padding required to center each block
				local padding = {}

				for block, block_width in pairs(widths) do
					padding[block] = math.max(0, math.floor((width - block_width) / 2))
				end

				-- Insert padding units at the beginning of each content line
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

	----------------------------------------------------------------------
	-- GENERAL COLORS
	----------------------------------------------------------------------

	-- Define highlight groups for dashboard elements
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

	----------------------------------------------------------------------
	-- AUTOCMDS
	----------------------------------------------------------------------

	-- Group dashboard events to allow them to be cleared or replaced together
	local group = vim.api.nvim_create_augroup("MiniStarterHeaderColors", { clear = true })

	-- Apply custom header colors after the dashboard has been rendered
	vim.api.nvim_create_autocmd("User", {
		group = group,
		pattern = "MiniStarterOpened",
		callback = function()
			vim.schedule(apply_header_colors)
		end,
	})

	-- Recalculate header highlight positions whenever the window is resized
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
	-- Avoid mapping plain keys to picker actions.
	-- nnn.nvim creates terminal-mode mappings inside the NNN buffer, which
	-- also capture input from programs launched by NNN. This breaks normal
	-- editing in nested editors, such as the batch-rename Neovim window.
	-- Enter already selects the current file, so NNN's native keybindings
	-- are sufficient.
	require("nnn").setup({
		picker = {
			cmd = "nnn", -- Use NNN as the picker backend
			session = "shared", -- Reuse the same NNN session across invocations
			tabs = false, -- Do not open NNN in separate tabs
			fullscreen = false, -- Display NNN inside a floating window

			style = {
				width = 0.9, -- Use 90% of the available editor width
				height = 0.8, -- Use 80% of the available editor height
				border = "double", -- Use a double-line floating window border
			},
		},

		offset = true, -- Account for editor offsets when positioning the picker
		replace_netrw = "picker", -- Replace netrw with the NNN picker
	})

	----------------------------------------------------------------------
	-- COLORS
	----------------------------------------------------------------------

	-- Customize NNN picker colors to match the OneDark theme
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
	-- Register icon definitions for filetypes, files, and LSP symbols
	require("mini.icons").setup()

	-- Replace the default LSP completion-kind icons with MiniIcons
	MiniIcons.tweak_lsp_kind()
end

----------------------------------------------------------------------
-- SNIPPETS
----------------------------------------------------------------------

-- Configure snippet expansion and navigation
require("mini.snippets").setup()

----------------------------------------------------------------------
-- COMPLETION
----------------------------------------------------------------------

do
	-- Configure completion behavior, documentation windows, and LSP integration
	require("mini.completion").setup({
		-- Delay (in milliseconds) before displaying completion-related UI
		delay = {
			completion = 100, -- Completion menu
			info = 100, -- Completion item documentation
			signature = 50, -- Function signature help
		},

		-- Floating window dimensions and borders
		window = {
			info = {
				height = 25,
				width = 80,
				border = "single",
			},

			signature = {
				height = 25,
				width = 80,
				border = "single",
			},
		},

		-- Use the built-in omnifunc interface for LSP completion
		lsp_completion = {
			source_func = "omnifunc",
			auto_setup = false, -- Configure omnifunc manually for each LSP server
		},

		-- Fallback to Vim's native completion when no source handles the request
		fallback_action = "<C-n>",

		-- Completion control and documentation navigation keybindings
		mappings = {
			force_twostep = "<C-Space>", -- Force two-step completion
			force_fallback = "<A-Space>", -- Force fallback completion
			scroll_down = "<C-f>", -- Scroll completion documentation down
			scroll_up = "<C-b>", -- Scroll completion documentation up
		},
	})

	----------------------------------------------------------------------
	-- COMPLETION KEYMAPS
	----------------------------------------------------------------------

	-- Navigate the completion menu using familiar movement keys.
	-- When the menu is closed, preserve each key's default behavior.
	-- Expression mappings return key sequences instead of executing commands.

	-- Tab / Down / Ctrl-j: select the next completion item
	vim.keymap.set("i", "<Tab>", function()
		if vim.fn.pumvisible() == 1 then
			return vim.keycode("<C-n>")
		end

		return vim.keycode("<Tab>")
	end, {
		expr = true,
		silent = true,
	})

	vim.keymap.set("i", "<Down>", function()
		if vim.fn.pumvisible() == 1 then
			return vim.keycode("<C-n>")
		end

		return vim.keycode("<Down>")
	end, {
		expr = true,
		silent = true,
	})

	vim.keymap.set("i", "<C-j>", function()
		if vim.fn.pumvisible() == 1 then
			return vim.keycode("<C-n>")
		end

		return vim.keycode("<C-j>")
	end, {
		expr = true,
		silent = true,
	})

	-- Up / Ctrl-k: select the previous completion item
	vim.keymap.set("i", "<Up>", function()
		if vim.fn.pumvisible() == 1 then
			return vim.keycode("<C-p>")
		end

		return vim.keycode("<Up>")
	end, {
		expr = true,
		silent = true,
	})

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
	-- Extend LSP capabilities with completion support from MiniCompletion
	local capabilities = require("mini.completion").get_lsp_capabilities()

	----------------------------------------------------------------------
	-- LUA
	----------------------------------------------------------------------

	vim.lsp.config("lua_ls", {
		capabilities = capabilities,

		filetypes = {
			"lua",
		},

		settings = {
			Lua = {
				diagnostics = {
					globals = {
						"vim", -- Recognize the Neovim API as a global variable
					},
				},

				workspace = {
					checkThirdParty = false, -- Disable third-party library prompts
				},

				telemetry = {
					enable = false, -- Disable telemetry
				},
			},
		},
	})

	----------------------------------------------------------------------
	-- NIX
	----------------------------------------------------------------------

	vim.lsp.config("nixd", {
		capabilities = capabilities,

		cmd = {
			"nixd",
		},

		filetypes = {
			"nix",
		},

		-- Detect project roots using the flake or Git repository
		root_markers = {
			"flake.nix",
			".git",
		},

		settings = {
			nixd = {
				-- Use the system's Nixpkgs expression for evaluation
				nixpkgs = {
					expr = "import <nixpkgs> { }",
				},

				-- Expose NixOS and Home Manager module options for completion
				options = {
					nixos = {
						-- Resolve the configuration matching the current hostname
						expr = string.format(
							"(builtins.getFlake (toString ./.)).nixosConfigurations.%s.options",
							vim.fn.hostname()
						),
					},

					-- Resolve options from the user's Home Manager configuration
					home_manager = {
						expr = "(builtins.getFlake (toString ./.)).homeConfigurations.gabrielzschmitz.options",
					},
				},
			},
		},
	})

	----------------------------------------------------------------------
	-- HTML
	----------------------------------------------------------------------

	vim.lsp.config("html", {
		capabilities = capabilities,

		filetypes = {
			"html",
		},
	})

	----------------------------------------------------------------------
	-- CSS
	----------------------------------------------------------------------

	vim.lsp.config("cssls", {
		capabilities = capabilities,

		filetypes = {
			"css",
			"scss",
			"less",
		},
	})

	----------------------------------------------------------------------
	-- C / C++
	----------------------------------------------------------------------

	vim.lsp.config("clangd", {
		capabilities = capabilities,

		cmd = {
			"clangd",
			"--background-index", -- Index the project in the background
			"--clang-tidy", -- Enable clang-tidy diagnostics
			-- Insert headers using Include-What-You-Use rules
			"--header-insertion=iwyu",
			"--completion-style=detailed", -- Show detailed completion information
			"--fallback-style=file:" .. vim.fn.stdpath("config") .. "/.clang-format",
		},

		filetypes = {
			"c",
			"cpp",
			"objc",
			"objcpp",
		},
	})

	----------------------------------------------------------------------
	-- GO
	----------------------------------------------------------------------

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
				gofumpt = true, -- Use gofumpt formatting rules
				staticcheck = true, -- Enable Staticcheck analysis

				-- Enable additional static analysis checks
				analyses = {
					unusedparams = true, -- Detect unused function parameters
					shadow = true, -- Detect variable shadowing
					nilness = true, -- Detect potential nil-related errors
					unusedwrite = true, -- Detect writes to unused variables
					useany = true, -- Suggest replacing interface{} with any
				},

				-- Display inferred types and values as inlay hints
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

	----------------------------------------------------------------------
	-- GO LINT
	----------------------------------------------------------------------

	-- Integrate golangci-lint diagnostics into the LSP client
	vim.lsp.config("golangci_lint_ls", {
		capabilities = capabilities,

		filetypes = {
			"go",
			"gomod",
			"gowork",
		},
	})

	----------------------------------------------------------------------
	-- PYTHON / RUFF
	----------------------------------------------------------------------

	-- Use Ruff for Python linting and diagnostics
	vim.lsp.config("ruff", {
		capabilities = capabilities,

		filetypes = {
			"python",
		},
	})

	----------------------------------------------------------------------
	-- BASH / SHELL
	----------------------------------------------------------------------

	vim.lsp.config("bashls", {
		capabilities = capabilities,

		filetypes = {
			"sh",
			"bash",
		},
	})

	----------------------------------------------------------------------
	-- ENABLE LSP SERVERS
	----------------------------------------------------------------------

	-- Register and activate the configured language servers
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

	-- Configure omnifunc for buffers attached to an LSP client
	-- This connects Neovim's built-in completion interface to MiniCompletion
	vim.api.nvim_create_autocmd("LspAttach", {
		callback = function(args)
			local client = vim.lsp.get_client_by_id(args.data.client_id)

			if client and client:supports_method("textDocument/completion") then
				vim.bo[args.buf].omnifunc = "v:lua.MiniCompletion.completefunc_lsp"
			end
		end,
	})

	-- Configure automatic text formatting for shell scripts
	vim.api.nvim_create_autocmd("FileType", {
		pattern = { "bash", "sh" },
		callback = function(args)
			vim.bo[args.buf].textwidth = 80 -- Wrap text at 80 columns
			vim.bo[args.buf].formatoptions = vim.bo[args.buf].formatoptions .. "ctq"
		end,
	})
end

----------------------------------------------------------------------
-- CONFORM
----------------------------------------------------------------------
-- Configure automatic code formatting through Conform.nvim
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
			"gofumpt", -- Apply stricter formatting rules than gofmt
			"goimports", -- Format imports and organize dependencies
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

	-- Customize formatter arguments
	formatters = {
		shfmt = {
			-- Use 2-space indentation, indent case statements, and simplify syntax
			prepend_args = { "-i", "2", "-ci", "-bn", "-sr" },
		},

		clang_format = {
			-- Use the ClangFormat configuration in the Neovim config directory
			prepend_args = { "-style=file:" .. vim.fn.stdpath("config") .. "/.clang-format" },
		},
	},

	--------------------------------------------------------------------
	-- Format on save
	--------------------------------------------------------------------

	format_on_save = function(bufnr)
		local filetype = vim.bo[bufnr].filetype

		-- Wrap shell-script comments to a maximum width of 80 characters
		if filetype == "bash" or filetype == "sh" then
			local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

			-- Process backwards so replacing lines does not affect pending indices
			for i = #lines, 1, -1 do
				local prefix, comment = lines[i]:match("^(%s*#%s?)(.*)$")

				if prefix and #lines[i] > 80 then
					-- Account for indentation and the comment marker in the line width
					local width = 80 - #prefix
					local wrapped = {}
					local current = ""

					-- Rebuild the comment by wrapping at word boundaries
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

		-- Use a 500 ms timeout and fall back to LSP formatting when needed
		return {
			timeout_ms = 500,
			lsp_fallback = true,
		}
	end,
})

----------------------------------------------------------------------
-- MARKDOWN PREVIEW
----------------------------------------------------------------------
-- Restrict Markdown Preview to Markdown buffers
vim.g.mkdp_filetypes = { "markdown" }

-- Print the preview URL when opening the browser
vim.g.mkdp_echo_preview_url = 1

-- Use a custom browser function to open the preview
vim.g.mkdp_browserfunc = "OpenMarkdownPreview"

-- Open preview URLs with the system's default browser
vim.cmd([[
	function! OpenMarkdownPreview(url)
		call jobstart(["xdg-open", a:url], {"detach": v:true})
	endfunction
]])

----------------------------------------------------------------------
-- SMEAR CURSOR
----------------------------------------------------------------------
-- Configure cursor movement animations
require("smear_cursor").setup({
	smear_between_buffers = true, -- Animate cursor movement between buffers
	-- Animate movement between adjacent lines
	smear_between_neighbor_lines = true,
	-- Allow cursor smearing into scrollable buffer space
	scroll_buffer_space = true,
	-- Support legacy computing symbols in cursor rendering
	legacy_computing_symbols_support = true,
	-- Background color used when transparency is unavailable
	transparent_bg_fallback_color = "#1e222a",
	smear_insert_mode = true, -- Animate cursor movement in Insert mode
	time_interval = 10, -- Update animation every 10 ms

	-- Disable cursor smearing in selected filetypes
	filetypes_disabled = {
		"minipick",
	},
})

----------------------------------------------------------------------
-- AUTOPAIRS
----------------------------------------------------------------------
-- Automatically insert and manage matching brackets, quotes, and delimiters
require("nvim-autopairs").setup({})

----------------------------------------------------------------------
-- GIT SIGNS
----------------------------------------------------------------------
-- Show Git change indicators in the sign column
require("gitsigns").setup({})

----------------------------------------------------------------------
-- TREESITTER
----------------------------------------------------------------------
-- Repair stale query symlinks left behind when the plugin checkout moves.
-- This is especially important for languages whose queries are not bundled
-- with Neovim, such as C and C++.
local function repair_treesitter_queries()
	local queries_dir = vim.fs.joinpath(vim.fn.stdpath("data"), "site", "queries")

	-- Skip repair if the shared query directory does not exist
	if vim.fn.isdirectory(queries_dir) == 0 then
		return
	end

	-- Find the currently installed nvim-treesitter package
	local package = vim.iter(vim.pack.get()):find(function(plugin)
		return plugin.spec.name == "nvim-treesitter"
	end)

	if not package then
		return
	end

	-- Check each query symlink against the current plugin checkout
	for name, kind in vim.fs.dir(queries_dir) do
		local link = vim.fs.joinpath(queries_dir, name)
		local source = vim.fs.joinpath(package.path, "runtime", "queries", name)

		-- Replace broken symlinks with links to the current checkout
		if kind == "link" and vim.fn.isdirectory(link) == 0 then
			vim.fn.delete(link)

			if vim.fn.isdirectory(source) == 1 then
				vim.uv.fs_symlink(source, link)
			end
		end
	end
end

-- Run the repair before configuring Tree-sitter
repair_treesitter_queries()

do
	-- Store installed parsers and query files in Neovim's shared data directory
	require("nvim-treesitter").setup({
		install_dir = vim.fn.stdpath("data") .. "/site",
	})

	-- Install parsers for the languages and file formats used in this setup
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

	-- Start Tree-sitter highlighting whenever a buffer's filetype is detected
	vim.api.nvim_create_autocmd("FileType", {
		callback = function()
			-- Ignore buffers without an available parser or compatible setup
			local ok = pcall(vim.treesitter.start)

			if not ok then
				return
			end
		end,
	})
end

----------------------------------------------------------------------
-- COLORIZER
----------------------------------------------------------------------
-- Highlight color values directly in buffers
require("colorizer").setup({
	filetypes = {
		"*", -- Enable color highlighting for all filetypes
	},

	user_default_options = {
		RGB = true, -- Highlight #RGB colors
		RRGGBB = true, -- Highlight #RRGGBB colors
		names = true, -- Highlight named colors
		RRGGBBAA = true, -- Highlight #RRGGBBAA colors
		AARRGGBB = true, -- Highlight #AARRGGBB colors
		css = true, -- Recognize CSS color properties
		css_fn = true, -- Recognize CSS color functions
		tailwind = false, -- Do not enable Tailwind color support
		mode = "background", -- Display colors using background highlighting
	},
})

----------------------------------------------------------------------
-- TABLINE
----------------------------------------------------------------------
do
	-- Display buffers in a tabline with filetype icons
	require("mini.tabline").setup({
		show_icons = true,

		-- Place tabpage indicators on the right side
		tabpage_section = "right",
	})

	--------------------------------------------------------------------
	-- COLORS
	--------------------------------------------------------------------

	-- Current buffer: emphasized with bold text
	vim.api.nvim_set_hl(0, "MiniTablineCurrent", {
		fg = "#b8bfe5",
		bg = "#5c6370",
		bold = true,
	})

	-- Visible inactive buffers: standard text contrast
	vim.api.nvim_set_hl(0, "MiniTablineVisible", {
		fg = "#abb2bf",
		bg = "#393f4a",
	})

	-- Hidden buffers: subdued text
	vim.api.nvim_set_hl(0, "MiniTablineHidden", {
		fg = "#5c6370",
		bg = "#393f4a",
	})

	-- Modified current buffer: emphasize the text and underline the indicator
	vim.api.nvim_set_hl(0, "MiniTablineModifiedCurrent", {
		fg = "#b8bfe5",
		bg = "#393f4a",
		bold = true,
		underline = true,
	})

	-- Modified visible buffers: underline to indicate unsaved changes
	vim.api.nvim_set_hl(0, "MiniTablineModifiedVisible", {
		fg = "#abb2bf",
		bg = "#393f4a",
		underline = true,
	})

	-- Modified hidden buffers: retain the subdued text and show the underline
	vim.api.nvim_set_hl(0, "MiniTablineModifiedHidden", {
		fg = "#5c6370",
		bg = "#393f4a",
		underline = true,
	})
end

----------------------------------------------------------------------
-- CURSOR WORD
----------------------------------------------------------------------
-- Highlight other occurrences of the word under the cursor
require("mini.cursorword").setup({
	delay = 100, -- Wait 100 ms before highlighting matching words
})

----------------------------------------------------------------------
-- LUALINE
----------------------------------------------------------------------
-- Configure the statusline using the OneDark theme
require("lualine").setup({
	options = {
		theme = "onedark", -- Use the OneDark color palette
		globalstatus = true, -- Use a single statusline across all windows
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
-- Configure MiniFuzzy's fuzzy matching algorithm
require("mini.fuzzy").setup()

----------------------------------------------------------------------
-- PICK
----------------------------------------------------------------------
do
	local MiniPick = require("mini.pick")

	-- Configure the picker behavior and floating window
	MiniPick.setup({
		options = {
			use_cache = true, -- Cache picker results when possible
		},

		window = {
			-- Center the picker and size it relative to the editor dimensions
			config = function()
				local height = math.floor(vim.o.lines * 0.35)
				local width = math.floor(vim.o.columns * 0.70)

				return {
					anchor = "NW",
					row = math.floor((vim.o.lines - height) / 2),
					col = math.floor((vim.o.columns - width) / 2),
					height = height,
					width = width,
					border = "single",
				}
			end,
		},
	})

	-- Use MiniPick as the implementation for vim.ui.select
	vim.ui.select = MiniPick.ui_select
end

do
	local set = vim.api.nvim_set_hl

	--------------------------------------------------------------------
	-- COLORS
	--------------------------------------------------------------------

	-- Picker window background and default text
	set(0, "MiniPickNormal", {
		bg = "#14171c",
		fg = "#abb2bf",
	})

	-- Standard picker border
	set(0, "MiniPickBorder", {
		fg = "#4889be",
		bg = "#14171c",
	})

	-- Border shown while the picker is processing
	set(0, "MiniPickBorderBusy", {
		fg = "#61afef",
		bg = "#14171c",
	})

	-- Text displayed in the picker border
	set(0, "MiniPickBorderText", {
		fg = "#61afef",
		bold = true,
	})

	-- Search prompt
	set(0, "MiniPickPrompt", {
		fg = "#61afef",
		bold = true,
	})

	-- Currently selected match
	set(0, "MiniPickMatchCurrent", {
		fg = "#14171c",
		bg = "#4889be",
		bold = true,
	})

	-- Matching characters in picker entries
	set(0, "MiniPickMatchRanges", {
		fg = "#61afef",
		bold = true,
	})

	-- Marked picker entries
	set(0, "MiniPickMatchMarked", {
		fg = "#14171c",
		bg = "#61afef",
		bold = true,
	})

	-- Preview window line highlight
	set(0, "MiniPickPreviewLine", {
		bg = "#181b21",
	})
end

-- ============================================================================
-- KEYMAPS
-- ============================================================================

local map = vim.keymap.set

-- Save the current buffer in Normal, Insert, and Visual modes
map({ "n", "i", "v" }, "<C-s>", "<cmd>w<cr>")

-- Use ; as a shortcut for entering command-line mode
map("n", ";", ":", { desc = "CMD enter command mode" })

-- Build a substitution command prefilled with the word under the cursor
map("n", "<leader>s", ":%s/\\<<C-r><C-w>\\>/<C-r><C-w>/gI<left><left><left>", {
	desc = "Substitute word under cursor",
})

-- Clear search highlighting
map("n", "<Esc>", "<cmd>nohlsearch<cr>", {
	desc = "Clear search highlight",
})

-- Move selected lines up or down while preserving the selection
map("v", "J", ":m '>+1<CR>gv=gv")
map("v", "K", ":m '<-2<CR>gv=gv")

-- Indent or unindent selected lines and keep them selected
map("v", "H", "<gv")
map("v", "L", ">gv")

----------------------------------------------------------------------
-- PLUGIN MANAGEMENT
----------------------------------------------------------------------

-- Update all plugins managed by vim.pack
local function update_plugins()
	-- Ensure the lockfile can be modified by vim.pack
	make_lockfile_writable()

	vim.pack.update()
end

-- Select and remove an installed plugin
local function remove_plugin()
	-- Ensure the lockfile can be modified by vim.pack
	make_lockfile_writable()

	local plugins = vim.pack.get()

	-- Stop if there are no installed plugins to remove
	if #plugins == 0 then
		vim.notify("No vim.pack plugins found", vim.log.levels.WARN)
		return
	end

	-- Build the selection list with each plugin's installation state
	local choices = {}

	for _, plugin in ipairs(plugins) do
		table.insert(choices, {
			name = plugin.spec.name,
			active = plugin.active,
			label = plugin.spec.name .. (plugin.active and " [active]" or ""),
		})
	end

	-- Prompt for a plugin to remove
	vim.ui.select(choices, {
		prompt = "Remove plugin from disk",
		format_item = function(item)
			return item.label
		end,
	}, function(choice)
		-- Do nothing if the selection was cancelled
		if not choice then
			return
		end

		-- Warn when removing a plugin that is still declared in the configuration
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

		-- Remove the selected plugin; force removal if it is currently active
		local ok, err = pcall(vim.pack.del, { choice.name }, {
			force = choice.active,
		})

		-- Report removal failures
		if not ok then
			vim.notify("Failed to remove " .. choice.name .. ": " .. tostring(err), vim.log.levels.ERROR)
			return
		end

		vim.notify("Removed " .. choice.name .. " from disk")
	end)
end

-- Plugin management keybindings
map("n", "<leader>pu", update_plugins, {
	desc = "Update plugins",
})

map("n", "<leader>pr", remove_plugin, {
	desc = "Remove plugin from disk",
})

----------------------------------------------------------------------
-- COMMENT
----------------------------------------------------------------------

-- Toggle comments for a range of lines using the current filetype's
-- commentstring
local function toggle_comment(start_line, end_line)
	local commentstring = vim.bo.commentstring

	-- Ensure the current filetype defines a comment format
	if commentstring == "" then
		vim.notify("No commentstring defined for this filetype", vim.log.levels.WARN)
		return
	end

	-- Split commentstring into its opening and closing delimiters
	local left, right = commentstring:match("^(.-)%%s(.-)$")

	if not left then
		vim.notify("Invalid commentstring: " .. commentstring, vim.log.levels.WARN)
		return
	end

	local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)

	-- Check whether every non-empty line already starts with the comment
	-- delimiter
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

	-- Add or remove comment delimiters while preserving indentation
	for i, line in ipairs(lines) do
		if line:match("%S") then
			local indent = line:match("^%s*")
			local content = line:sub(#indent + 1)

			if all_commented then
				-- Remove the opening and closing delimiters
				content = content:gsub("^" .. vim.pesc(left), "", 1)
				content = content:gsub("^" .. vim.pesc(right), "", 1)
				content = content:gsub("^ ", "", 1)
			else
				-- Wrap the line content in the comment delimiters
				content = left .. " " .. content .. right
			end

			lines[i] = indent .. content
		end
	end

	-- Replace the original range with the updated lines
	vim.api.nvim_buf_set_lines(0, start_line - 1, end_line, false, lines)
end

-- Toggle the comment on the current line
vim.keymap.set("n", "<leader>/", function()
	local line = vim.fn.line(".")
	toggle_comment(line, line)
end, {
	desc = "Toggle comment",
})

-- Toggle comments across the selected Visual range
vim.keymap.set("x", "<leader>/", function()
	local start_line = vim.fn.line("v")
	local end_line = vim.fn.line(".")

	-- Normalize the range regardless of selection direction
	if start_line > end_line then
		start_line, end_line = end_line, start_line
	end

	toggle_comment(start_line, end_line)

	-- Exit Visual mode after applying the comment operation
	vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "nx", false)
end, {
	desc = "Toggle comment selection",
})

----------------------------------------------------------------------
-- DASHBOARD
----------------------------------------------------------------------

-- Open the MiniStarter dashboard
map("n", "<leader>h", "<cmd>lua MiniStarter.open()<cr>", {
	desc = "Open dashboard",
})

----------------------------------------------------------------------
-- GITSIGNS
----------------------------------------------------------------------

-- Show Git blame information for the current line
map("n", "<leader>gb", "<cmd>Gitsigns blame_line<cr>", {
	desc = "Git blame line",
})

-- Show the Git diff for the current buffer
map("n", "<leader>gd", "<cmd>Gitsigns diffthis<cr>", {
	desc = "Git diff",
})

-- Preview changes in the current Git hunk
map("n", "<leader>gp", "<cmd>Gitsigns preview_hunk<cr>", {
	desc = "Preview git hunk",
})

-- Discard changes in the current Git hunk
map("n", "<leader>gr", "<cmd>Gitsigns reset_hunk<cr>", {
	desc = "Reset git hunk",
})

-- Stage changes in the current Git hunk
map("n", "<leader>gs", "<cmd>Gitsigns stage_hunk<cr>", {
	desc = "Stage git hunk",
})

----------------------------------------------------------------------
-- NNN
----------------------------------------------------------------------

-- Open the NNN file explorer picker
map("n", "<leader>e", "<cmd>NnnPicker<cr>", {
	desc = "Toggle file explorer",
})

----------------------------------------------------------------------
-- FUZZY SEARCH
----------------------------------------------------------------------

-- Search for files in the current working directory
map("n", "<leader>f", function()
	MiniPick.builtin.files()
end, {
	desc = "Find files",
})

-- Search file contents interactively using live grep
map("n", "<leader>F", function()
	MiniPick.builtin.grep_live()
end, {
	desc = "Find word",
})

----------------------------------------------------------------------
-- LSP KEYMAPS
----------------------------------------------------------------------

-- Navigate to the symbol definition
map("n", "gd", vim.lsp.buf.definition, {
	desc = "Go to definition",
})

-- Navigate to the symbol declaration
map("n", "gD", vim.lsp.buf.declaration, {
	desc = "Go to declaration",
})

-- Find references to the symbol under the cursor
map("n", "gr", vim.lsp.buf.references, {
	desc = "Find references",
})

-- Display hover documentation for the symbol under the cursor
map("n", "K", vim.lsp.buf.hover, {
	desc = "Hover documentation",
})

-- Rename the symbol across the workspace
map("n", "<leader>rn", vim.lsp.buf.rename, {
	desc = "Rename symbol",
})

-- Populate and open the location list with diagnostics from the current buffer
map("n", "<leader>E", function()
	vim.diagnostic.setloclist({
		open = true,
	})
end, {
	desc = "Show file diagnostics",
})
