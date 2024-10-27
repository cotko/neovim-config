local mod = {}

-- holds registered settings
local settings = {}

-- holds "global" settings + any settings specific to workspace
local settings_ns = {
  global = {}
}


mod.load_settings = function()
end


mod.get_settings = function()
  return settings
end

mod.get_settings_ns = function()
  return settings_ns
end



mod.add_setting = function(setting)
  table.insert(settings, setting)
end

return mod
