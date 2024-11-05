local nls = require('null-ls')
local biome = require('plugins.my.linters.biome-nls')

nls.setup({
  sources = {
    nls.builtins.formatting.stylua,
    -- biome is provided by lsp
    -- mod.builtins.formatting.biome,

    nls.builtins.code_actions.gitsigns,

    --nls.builtins.completion.luasnip,

    nls.builtins.diagnostics.fish,
    --nls.builtins.diagnostics.todo_comments,
  },
})

biome.register()
