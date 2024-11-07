local misc = require('plugins.ui.misc')
local ok, neocodeium = nil, nil

local  symbols = {
  status = {
    [0] = '󰚩 ', -- Enabled
    [1] = '󱚧 ', -- Disabled Globally
    [2] = '󱙻 ', -- Disabled for Buffer
    [3] = '󱙺 ', -- Disabled for Buffer filetype
    [4] = '󱙺 ', -- Disabled for Buffer with enabled function
    [5] = '󱚠 ', -- Disabled for Buffer encoding
  },
  server_status = {
    [0] = '󰣺 ', -- Connected
    [1] = '󰣻 ', -- Connecting
    [2] = '󰣽 ', -- Disconnected
  },
}

local function do_require()
  if ok == nil then
    ok, neocodeium = pcall(require, 'neocodeium')
  end
end

vim.api.nvim_create_autocmd('User', {
  pattern = 'SetupComplete',
  callback = do_require
})

return function()
  return {
    function()
      if not ok then return '(no AI)' end
      local status, server_status = neocodeium.get_status()

      return 'codeium ('
        .. symbols.status[status]
        .. symbols.server_status[server_status]
        .. ')'
    end,
    separator = misc.separator,
    icon = {
      '  ',
      align='right',
      color = function()
        return ok and 'Added' or ''
      end
    },
    on_click = function()
      vim.cmd('NeoCodeium toggle')
    end
  }

end
