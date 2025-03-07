require('conform').setup({
  -- Map of filetype to formatters
  formatters_by_ft = {
    javascript = {
      'biome',
      stop_after_first = true,
      lsp_format = 'fallback',
    },
    typescript = {
      'biome',
      stop_after_first = true,
      lsp_format = 'fallback',
    },
    json = {
      'jq',
      'biome',
      stop_after_first = true,
      lsp_format = 'fallback',
    },
    jsonc = {
      'jq',
      'biome',
      stop_after_first = true,
      lsp_format = 'fallback',
    },
    lua = { 'stylua' },
  },

  formatters = {
  },
})

vim.api.nvim_create_user_command(
  'Format',
  function(args)
    local range = nil
    if args.count ~= -1 then
      local end_line = vim.api.nvim_buf_get_lines(
        0,
        args.line2 - 1,
        args.line2, true
      )[1]

      range = {
        start = {
          args.line1,
          0,
        },
        ['end'] = {
          args.line2,
          end_line:len(),
        },
      }
    end
    require('conform').format({
      async = true,
      lsp_format = 'fallback',
      range = range,
    })
  end,
  {
    range = true,
  }
)
