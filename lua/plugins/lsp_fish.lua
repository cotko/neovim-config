local lsp = require 'lspconfig'
local configs = require 'lspconfig.configs'

if not configs.fish_lsp then
  configs.fish_lsp_lsp = {
    default_config = {
      cmd = { 'fish-lsp', 'start' },
      filetypes = { 'fish' },
      root_dir = function(fname)
        return vim.fs.dirname(
          vim.fs.find('.git', { path = fname, upward = true }
        )[1])
      end,
      settings = {},
    },
  }
end

lsp.fish_lsp.setup {}

vim.api.nvim_create_autocmd('FileType', {
  pattern = 'fish',
  callback = function(args)
    -- local match = vim.fs.find(root_markers, { path = args.file, upward = true })[1]
    -- local root_dir = match and vim.fn.fnamemodify(match, ':p:h') or nil
    vim.lsp.start {
      cmd = { 'fish-lsp', 'start' },
      settings = {},
    }
  end,
})
