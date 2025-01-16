local fn = {}

local did_require = false

local has_smvn = false

---@module 'supermaven-nvim.api'
local smvn_api = nil
---@module 'supermaven-nvim.completion_preview'
local smvn_cpl = nil


local has_ncd = false
---@module 'neocodeium'
local ncd = nil

fn.accept_aviailable = function()
  fn.do_require()

  if has_smvn
    and smvn_api.is_running()
    and smvn_cpl.has_suggestion()
  then
    print('accepting supermaven')
    smvn_cpl.on_accept_suggestion()
    return
  end

  if has_ncd and ncd.visible() then
    print('accepting neocodeium')
    ncd.accept()
    return
  end

end

fn.cycle = function(backwards)
  if has_ncd and ncd.visible() then
    if backwards then ncd.cycle(-1) else ncd.cycle(1) end
    return
  end
end

fn.clear = function()
  if has_ncd and ncd.visible() then
    ncd.clear()
  end
  if has_smvn and smvn_cpl.has_suggestion() then
    smvn_cpl.on_dispose_inlay()
  end
end


fn.do_require = function()
  if did_require then return end

  has_smvn, smvn_api = pcall(require, 'supermaven-nvim.api')
  if has_smvn then
    smvn_api = require('supermaven-nvim.api')
    smvn_cpl = require('supermaven-nvim.completion_preview')
  end

  has_ncd, ncd = pcall(require, 'neocodeium')

  did_require = true
end





return fn
