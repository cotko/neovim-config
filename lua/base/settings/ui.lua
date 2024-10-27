local settings_fn = require('base.settings.fn')
local mod = {}
mod.pane = nil
mod.tree = nil

mod.get_settings = function()
  local nui_tree = require('nui.tree')

  local nodes = {}
  for _, setting in ipairs(settings_fn.get_settings()) do
    local node = nui_tree.Node({
      text = setting.label,
    })

    table.insert(nodes, node)
  end

  return nodes

end

mod.create_node_text = function (node)
end

mod.init = function()
  local nui_tree = require('nui.tree')
  local nui_split = require('nui.split')
  local nui_text = require('nui.text')
  local nui_line = require('nui.line')
  local event = require('nui.utils.autocmd').event

  if mod.pane ~= nil then return end

  mod.split = nui_split({
    relative = 'editor',
    position = 'right',
    size = 30,
    enter = true,
  })

  mod.tree = nui_tree({
    bufnr = 0,
    winid = mod.split.winid,
    nodes = mod.get_settings(),
    --prepare_node = function(node)
    --  return mod.create_node_text(node)
    --end,
  })

  mod.split:mount()
  mod.tree:render()
end

mod.open = function()
  mod.init()
end

mod.toggle = function()
  mod.init()
end


vim.api.nvim_create_autocmd('User', {
  pattern = 'SetupComplete',
  callback = function()
    local md = require('mini.deps')
    md.later(function()
      mod.init()
    end)
  end
})
