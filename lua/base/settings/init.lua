local settings_ui = require('base.settings.ui')
local settings_fn = require('base.settings.fn')


vim.api.nvim_create_autocmd('User', {
  pattern = 'RegisterSetting',
  callback = function(evt)
    settings_fn.add_setting(evt.data)
  end
})
