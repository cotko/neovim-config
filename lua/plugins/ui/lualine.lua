local workspaces_ok, workspaces = pcall(require, 'workspaces')
local ai = require('plugins.ui.ai')
local lsp = require('plugins.ui.lsp')
local misc = require('plugins.ui.misc')
local lualine_mode = require('lualine.utils.mode')

local unpack = table.unpack or unpack

local section_config = {
  lualine_a = {
    {
      function()
        return vim.o.ft == 'NvimTree'
          and vim.fn.fnamemodify(vim.fn.getcwd(), ':~')
          or lualine_mode.get_mode()
      end
    },
    'searchcount',
    'selectioncount',
  },
  lualine_b = {},
  lualine_c = {},
  lualine_x = {
    misc.indent(),
    misc.ignorecase(),
    misc.hl_search(),
    {'encoding', separator = misc.separator},
    -- {'fileformat', separator = misc.separator},
    {'filetype', separator = misc.separator},
    {'filesize', separator = misc.separator},
  },
  lualine_y = {'progress'},
  lualine_z = {'location'},
}

require('lualine').setup({
  options = {
    --theme = 'ayu_mirage',
    --section_separators = '',
    --component_separators = '',

    globalstatus = true,

    disabled_filetypes = {
      statusline = {
        --'NvimTree',
        --'', -- empty buffers
      },
      winbar = {
        'NvimTree',
        '', -- empty buffers
      },
    },

  },

  sections = section_config,
  inactive_sections = section_config,

  tabline = {
    lualine_a = {{
      function ()
        if workspaces_ok then
          local workspace = workspaces.name()
          if workspace ~= nil then return workspace end
        end
        return '(no workspace)'
      end,
      on_click = function(_, which)
        local workspace = workspaces.name()
        if workspace ~= nil then
          vim.cmd('WorkspacesOpen')
          return
        end
        if which == 'l' then
          vim.cmd('WorkspacesOpen')
        else
          vim.cmd('WorkspacesAdd')
        end
      end
    }},
    lualine_b = {},
    lualine_c = {
      {
      'branch',
      on_click = function()
        -- get cwd for file in case neovim is not
        -- at git path
        -- :p - absolute path
        -- :h remove file name and jsut keep dir
        local cwd = vim.fn.expand('%:p:h')
        require('telescope.builtin').git_branches({
          cwd = cwd
        })
      end
    },
    {
      'diff',
      on_click = function()
        vim.cmd('Gitsigns diffthis')
      end
    },
    {
      'diagnostics',
      sources = {
        'nvim_lsp',
        'nvim_diagnostic',
        'nvim_workspace_diagnostic',
      },
      on_click = function()
        vim.cmd('Telescope diagnostics')
      end
    }},
    lualine_x = {
      (function()
        local tbl = { unpack(ai()) }
        table.insert(tbl, lsp())
        return unpack(tbl)
      end)()
    },
    lualine_y = {},
    lualine_z = {{
      'datetime',
      style = '\'%H:%M',
    }}
  },

  winbar = {
    lualine_a = {{
      'filename',
      separator = { left = ' ', right = ' '},
    }},
    lualine_b = {},
    lualine_c = {},
    lualine_x = {},
    lualine_y = {},
    lualine_z = {}
  },
  inactive_winbar = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = {{
      'filename',
      separator = { left = ' ', right = ' '},
    }},
    lualine_x = {},
    lualine_y = {},
    lualine_z = {}
  },

  extensions = {
    --'nvim-tree',
    'mason',
  }
})
