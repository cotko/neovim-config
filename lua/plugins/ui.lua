local workspaces_ok, workspaces = pcall(require, 'workspaces')

require('lualine').setup({
  options = {
    theme = 'ayu_mirage',
    --section_separators = '',
    --component_separators = '',

    globalstatus = true,

    disabled_filetypes = {
      statusline = {
        --'NvimTree',
        '', -- empty buffers
      },
      winbar = {
        'NvimTree',
        '', -- empty buffers
      },
    },

  },

  sections = {
    lualine_a = {'mode', 'searchcount', 'selectcount'},
    lualine_b = {},
    lualine_c = {},
    lualine_x = {'encoding', 'fileformat', 'filetype', 'filesize'},
    lualine_y = {'progress'},
    lualine_z = {'location'}
  },
  inactive_sections = {
    lualine_a = {'mode', 'searchcount', 'selectcount'},
    lualine_b = {},
    lualine_c = {},
    lualine_x = {'encoding', 'fileformat', 'filetype', 'filesize'},
    lualine_y = {'progress'},
    lualine_z = {'location'}
  },

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
    lualine_x = {{
      function()
        ---@type string|boolean
        local label = false
        local bufnr = vim.api.nvim_get_current_buf()
        local clients = vim.lsp.get_clients({ bufnr = bufnr })
        for _, client in ipairs(clients) do
          if client.attached_buffers[bufnr] then
            label = label and label .. ' ' .. client.name or client.name
          end
        end

        return label or '(no clients)'
      end,
      icon = { 'LSP', align='right', color='Added'},
      on_click = function()
        vim.cmd('LSPToggler')
      end
    }},
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
    'nvim-tree',
    'mason',
  }
})
