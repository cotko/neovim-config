require('base.globals')
require('fn')
require('base.setup')
require('base.config')
require('base.packages')
require('plugins.my')

require('mini.deps').later(
  function()
    vim.api.nvim_exec_autocmds(
      'User',
      { pattern = 'SetupComplete' }
    )
  end
)
