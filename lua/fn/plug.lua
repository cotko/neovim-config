local fn = {}
local ok_lualine, lualine = nil, nil

local function require_lualine()
  if ok_lualine == nil then
    ok_lualine, lualine = pcall(require, 'lualine')
  end
end

fn.wrap_lualine_refresh = function(cb)
  return function()
    cb()
    require_lualine()
    if ok_lualine then
      lualine.refresh()
    end
  end
end

fn.ui_refresh = function()
  require_lualine()
  if not ok_lualine then return false end
  lualine.refresh()
  return true
end

return fn
