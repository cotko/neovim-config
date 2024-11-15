local misc = require('plugins.ui.misc')
local ok_neocodeium, neocodeium = nil, nil
local ok_supermaven, supermaven = nil, nil

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
  if ok_neocodeium == nil then
    ok_neocodeium, neocodeium = pcall(require, 'neocodeium')
  end
  if ok_supermaven == nil then
    ok_supermaven, supermaven = pcall(require, 'supermaven-nvim.api')
  end
end

vim.api.nvim_create_autocmd('User', {
  pattern = 'SetupComplete',
  callback = do_require
})

local function codeiumLine()
  return {
    function()
      if not ok_neocodeium then return '' end
      local status, server_status = neocodeium.get_status()

      return 'codeium ('
        .. symbols.status[status]
        .. symbols.server_status[server_status]
        .. ')'
    end,
    separator = misc.separator,
    color = function()
      if not ok_neocodeium then return '' end
      local status, server_status = neocodeium.get_status()
      return (status == 0 and server_status == 0) and 'Added' or ''
    end,
    on_click = FNS.plug.wrap_lualine_refresh(function()
      vim.cmd('NeoCodeium toggle')
    end)
  }
end

local function supermavenLine()
  return {
    function()
      if not ok_supermaven then return '' end
      local running = supermaven.is_running()

      return 'supermaven ('
        .. symbols.status[running and 0 or 1]
        .. ')'
    end,
    separator = '',
    color = function()
      return (ok_supermaven and supermaven.is_running())
        and 'Added' or ''
    end,
    on_click = FNS.plug.wrap_lualine_refresh(function()
      vim.cmd('SupermavenToggle')
    end)
  }
end


return function()
  return {
    codeiumLine(),
    supermavenLine(),
    {
      function()
        return (ok_neocodeium or ok_supermaven) and '' or '(no AI) '
      end,
      separator = misc.separator,
      color = function()
        return (ok_neocodeium or ok_supermaven) and 'Added' or ''
      end
    }
  }

end
