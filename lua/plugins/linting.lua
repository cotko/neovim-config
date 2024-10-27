local lint = require('lint')
local biome = require('plugins.linters.biome')

local function setup()
  -- You can disable the default linters by setting their filetypes to nil:
  -- lint.linters_by_ft['clojure'] = nil
  -- lint.linters_by_ft['dockerfile'] = nil

  lint.linters.biome = biome()
  local ns = lint.get_namespace('biome')
  vim.diagnostic.config({
    virtual_text = {
      format = function(diag)
        if diag.user_data == nil then
          print('wtf' .. vim.inspect(diag))
          return '??'
        end

        return diag.user_data.header
      end
    }
  }, ns)

  lint.linters_by_ft = {
    javascript = { 'biome' },
    typescript = { 'biome' },
    javascriptreact = { 'biome' },
    typescriptreact = { 'biome' },
    json = { 'biome' },
    jsonc = { 'biome' },
    css = { 'biome' },
    graphql = { 'biome' },
  }

end


local function init()
  local lint_augroup = vim.api.nvim_create_augroup(
    'lint', { clear = true })

  vim.api.nvim_create_autocmd({
    'BufEnter',
    'BufWritePost',
    'InsertLeave',
  }, {
      group = lint_augroup,
      callback = function()
        lint.try_lint()
      end,
    })
end


setup()
init()
