require('fidget').setup({

  integration = {
    ['nvim-tree'] = { enable = true },
  },

  notification = {
    override_vim_notify = true,

    window = {
      winblend = 0,
      border = "rounded",
    },
  },

})

-- local levels = {
--   [0] = 'TRACE',
--   [1] = 'DEBUG',
--   [2] = 'INFO',
--   [3] = 'WARN',
--   [4] = 'ERROR',
--   [5] = 'OFF',
-- }
-- 
-- local notify = vim.notify
-- vim.notify = function(msg, level, opts)
--   print(levels[level] .. ': ' .. msg)
--   notify(msg, level, opts)
-- end
