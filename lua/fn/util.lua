local fn = {}

fn.setIndent = function (ref, indent, tabs)
  local expandtab = not tabs

  -- ref.breakindent = true
  ref.sts = indent
  ref.sw = indent
  ref.ts = indent
  ref.expandtab = expandtab
  ref.smartindent = true
end

fn.toggleIndents = function ()
  local indent = vim.g.ts
  local tabs = false
  if indent == 2 and vim.g.expandtab then
    indent = 4
  elseif indent == 4 and vim.g.expandtab then
    indent = 4
    tabs = true
  else
    indent = 2
  end

  fn.setIndent(vim.g, indent, tabs)
  fn.setIndent(vim.opt, indent, tabs)

  vim.notify(
    (not tabs and (indent .. ' spaces') or 'tabs') .. ' identation',
    2
  )
end

fn.toggleLineNumbering = function()
  local nl = vim.o.relativenumber and vim.o.number
  vim.o.number = not nl
  vim.o.relativenumber = not nl
end

fn.toggleHlSearch = function()
  vim.o.hlsearch = not vim.o.hlsearch
  vim.notify('hl search: ' .. vim.inspect(vim.o.hlsearch))
end

fn.get_project_root = function()
  return vim.fn.getcwd()
end

fn.which = function(cmd)
  return vim.fn.systemlist('PATH=/usr/bin:$PATH which ' .. cmd)[1]
end

fn.register_setting = function(s)
  vim.api.nvim_exec_autocmds(
    'User',
    { pattern = 'RegisterSetting', data = s }
  )
end

fn.inspect_lsp_client = function()
  -- taken from here https://www.reddit.com/r/neovim/comments/1gf7kyn/lsp_configuration_debugging/
  vim.ui.input({ prompt = 'Enter LSP Client name: ' }, function(client_name)
    if client_name then
      local client = vim.lsp.get_clients { name = client_name }

      if #client == 0 then
        vim.notify('No active LSP clients found with this name: ' .. client_name, vim.log.levels.WARN)
        return
      end

      -- Create a temporary buffer to show the configuration
      local buf = vim.api.nvim_create_buf(false, true)
      local win = vim.api.nvim_open_win(buf, true, {
        relative = 'editor',
        width = math.floor(vim.o.columns * 0.75),
        height = math.floor(vim.o.lines * 0.90),
        col = math.floor(vim.o.columns * 0.125),
        row = math.floor(vim.o.lines * 0.05),
        style = 'minimal',
        border = 'rounded',
        title = ' ' .. (client_name:gsub('^%l', string.upper)) .. ': LSP Configuration ',
        title_pos = 'center',
      })

      local lines = {}
      for i, this_client in ipairs(client) do
        if i > 1 then
          table.insert(lines, string.rep('-', 80))
        end
        table.insert(lines, 'Client: ' .. this_client.name)
        table.insert(lines, 'ID: ' .. this_client.id)
        table.insert(lines, '')
        table.insert(lines, 'Configuration:')

        local config_lines = vim.split(vim.inspect(this_client.config), '\n')
        vim.list_extend(lines, config_lines)
      end

      -- Set the lines in the buffer
      vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

      -- Set buffer options
      vim.bo[buf].modifiable = false
      vim.bo[buf].filetype = 'lua'
      vim.bo[buf].bh = 'delete'

      vim.api.nvim_buf_set_keymap(buf, 'n', 'q', ':q<CR>', { noremap = true, silent = true })
    end
  end)
end


fn.nvim_tree_get_node = function(node)
  if node then return node end

  local core = require('nvim-tree.core')
  local explorer = core.get_explorer()
  if not explorer then return nil end
  return explorer.get_node_at_cursor(explorer)
end

fn.wrap_bufnr = function(cb)
  return function(bufnr)
    return cb(bufnr or vim.api.nvim_get_current_buf())
  end
end

fn.get_buf_ft = function(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  return vim.api.nvim_get_option_value('filetype', { buf = bufnr })
end


fn.get_buffer_name = fn.wrap_bufnr(function(bufnr)
  local name = vim.api.nvim_buf_get_name(bufnr)
  return vim.fn.fnamemodify(name, ':t')
end)

return fn
