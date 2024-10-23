local G = vim.g
local O = vim.opt

G.mapleader = ","
G.maplocalleader = ","

-- disable netrw
G.loaded_netrw = 1
G.loaded_netrwPlugin = 1

-- enable 24-bit colour
O.termguicolors = true

------------------------
------------------------
-----  Settings
----    See `:help vim.o`
------------------------
------------------------

O.laststatus = 3 -- global statusline
O.mouse = "a" -- nil
O.guicursor = ""

-- Sync clipboard between OS and Neovim.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
O.clipboard = "unnamedplus"

O.relativenumber = true
O.number = true
O.list = true
-- O.listchars = "tab:▸ ,eol:¬,trail:~"
-- O.listchars = "tab:  ,eol:¬,trail:~"
O.listchars = "tab:  ,trail:~"

O.swapfile = false
O.backup = false

O.undodir = vim.fn.stdpath("state") .. "/undodir"
O.undofile = true
O.undolevels = 10000

O.hlsearch = false
O.incsearch = true
-- Case insensitive searching UNLESS /C or capital in search
O.ignorecase = true
O.smartcase = true

-- set termguicolors to enable highlight groups
O.termguicolors = true

O.scrolloff = 8
O.signcolumn = "yes"
O.colorcolumn = "85"
O.isfname:append("@-@")

-- Decrease update time
O.updatetime = 250 -- was 50 before
O.timeoutlen = 300

O.virtualedit = "block" -- Allow cursor to move where there is no text in visual block mode
O.wildmode = "longest:full,full" -- Command-line completion mode
O.winminwidth = 5 -- Minimum window width

-- https://www.reddit.com/r/neovim/comments/i5iptq/comment/g0vpn8j
O.grepprg = "rg --vimgrep"

-- Set completeopt to have a better completion experience
O.completeopt = "menuone,noselect"

O.pumblend = 10 -- Popup blend
O.pumheight = 10 -- Maximum number of entries in a popup

-- https://www.reddit.com/r/neovim/comments/njew3z/treesitter_code_folding/
O.foldmethod = "expr"
O.foldexpr = "nvim_treesitter#foldexpr()"
O.foldlevelstart = 99

O.sessionoptions = { "buffers", "curdir", "tabpages", "winsize", "help", "globals", "skiprtp", "folds" }

-- { from Kickstart
--
-- Don't show the mode, since it's already in the status line
O.showmode = false
-- O.breakindent = true

-- Configure how new splits should be opened
O.splitright = true
O.splitbelow = true
O.splitkeep = "screen"

-- Preview substitutions live, as you type!
O.inccommand = "split"

-- Show which line your cursor is on
O.cursorline = true



vim.api.nvim_create_autocmd('User', {
  pattern = 'SetupComplete',
  callback = function()
    FNS.util.setIndent(G, DefaultIndent)
    FNS.util.setIndent(O, DefaultIndent)
  end
})
