local ensure_installed = {
  'bash',
  'c',
  'cmake',
  'cpp',
  'css',
  'dockerfile',
  'fish',
  'glimmer', -- hbs
  'go',
  'html',
  'java',
  'javascript',
  'json',
  'jsonc',
  'kotlin',
  'latex',
  'lua',
  'luadoc',
  'markdown',
  'markdown_inline',
  'php',
  'python',
  'query',
  'regex',
  'rust',
  'sql',
  'svelte',
  'toml',
  'tsx',
  'typescript',
  'vim',
  'yaml',
}

require('nvim-treesitter.configs').setup({
  ensure_installed = ensure_installed,
  -- Autoinstall languages that are not installed
  auto_install = true,
  highlight = {
    enable = true,
    use_languagetree = true,
    additional_vim_regex_highlighting = { 'ruby' },
  },
  incremental_selection = {
    enable = true,
    keymaps = {
      init_selection = "<CR>",
      node_incremental = "<CR>",
      scope_incremental = "gsi",
      node_decremental = "<BS>",
    },
  },
  indent = {
    enable = true,
  },
  textobjects = {
    select = {
      enable = true,

      -- Automatically jump forward to textobj,
      -- similar to targets.vim
      lookahead = true,

      keymaps = {
        ["af"] = "@function.outer",
        ["if"] = "@function.inner",
        ["ac"] = "@class.outer",
        ["ic"] = "@class.inner"
      },
      -- You can choose the select mode (default is charwise 'v')
      selection_modes = {
        ['@parameter.outer'] = 'v', -- charwise
        ['@function.outer'] = 'V', -- linewise
        ['@class.outer'] = '<c-v>', -- blockwise
      },
      -- If you set this to `true` (default is `false`)
      -- then any textobject is
      -- extended to include preceding or succeeding 
      -- whitespace. 
      -- Succeeding whitespace has priority in order to act
      -- similarly to eg the built-in `ap`.
      include_surrounding_whitespace = false,
    },
    lsp_interop = {
      enable = true,
      border = 'none',
      peek_definition_code = {
        ["<leader>lf"] = "@function.outer",
        ["<leader>lF"] = "@class.outer",
      },
    },
  },
})

-- Disable injections in 'lua' language. In Neovim<0.9 it is
-- `vim.treesitter.query.set_query()`; in Neovim>=0.9 it is
-- `vim.treesitter.query.set()`.
local ts_query = require('vim.treesitter.query')
local ts_query_set = ts_query.set or ts_query.set_query
ts_query_set('lua', 'injections', '')
