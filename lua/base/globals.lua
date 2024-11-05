PluginSource = vim.fn.stdpath('config') .. '/lua/plugins/'

ColorScheme = 'onedark'
--ColorScheme = 'alduin'
DefaultIndent = 2
DefaultFontSize = 14
DefaultFont = 'RobotoMono Nerd Font'

AuGroup = 'cotko'

--CompletionModule = 'coq'
CompletionModule = 'blink'

-- my custom funcions will be added here
FNS = {}

vim.api.nvim_create_augroup(AuGroup, { clear = true })


if CompletionModule == 'coq' then
  vim.g.coq_settings = {
    -- shut up removes weird hello message
    auto_start = 'shut-up', -- if you want to start COQ at startup
  }
end
