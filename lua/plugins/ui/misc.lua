local m = {}

-- m.separator = '|'
m.separator = '·'

m.separate = function()
  return {
    function() return '' end,
    separator = m.separator,
    draw_empty = true,
  }
end


m.indent = function()
  return {
    function()
      return not vim.g.expandtab and 'tabs'
        or vim.g.ts == 2 and '2 spaces'
        or '4 spaces'
    end,
    separator = m.separator,
    on_click = FNS.util.toggleIndents
  }
end

m.ignorecase = function()
  return {
    'vim.o.ignorecase and "ic" or "noic"',
    separator = m.separator,
    on_click = FNS.util.toggleIgnoreCase
  }
end

m.hl_search = function()
  return {
    'vim.o.hlsearch and "hl" or "nohl"',
    separator = m.separator,
    on_click = FNS.util.toggleHlSearch
  }
end



return m
