local function get_clients()
  ---@type string|boolean
  local label = false
  local bufnr = vim.api.nvim_get_current_buf()
  local clients = vim.lsp.get_clients({ bufnr = bufnr })
  for _, client in ipairs(clients) do
    if client.attached_buffers[bufnr] then
      label = label and label .. ' ' .. client.name or client.name
    end
  end

  return label
end

return function()
  return {
    function()
      return get_clients() or '(no clients)'
    end,
    icon = {
      ' 󰉶 ',
      --'LSP',
      align='right',
      color = function()
        return get_clients() and 'Added' or ''
      end
    },
    on_click = function()
      vim.cmd('LSPToggler')
    end
  }
end
