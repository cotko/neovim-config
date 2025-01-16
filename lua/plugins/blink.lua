if CompletionModule ~= 'blink' then
  return
end

-- fallbacks are needet so blink does not eat up keys like "tab" etc
require('blink.cmp').setup({
  keymap = {
    ['<A-1>'] = { function(cmp) cmp.accept({ index = 1 }) end },
    ['<A-2>'] = { function(cmp) cmp.accept({ index = 2 }) end },
    ['<A-3>'] = { function(cmp) cmp.accept({ index = 3 }) end },
    ['<A-4>'] = { function(cmp) cmp.accept({ index = 4 }) end },
    ['<A-5>'] = { function(cmp) cmp.accept({ index = 5 }) end },
    ['<A-6>'] = { function(cmp) cmp.accept({ index = 6 }) end },
    ['<A-7>'] = { function(cmp) cmp.accept({ index = 7 }) end },
    ['<A-8>'] = { function(cmp) cmp.accept({ index = 8 }) end },
    ['<A-9>'] = { function(cmp) cmp.accept({ index = 9 }) end },

    ['<Tab>'] = { 'select_and_accept', 'fallback' },
    -- ['<Tab>'] = 'accept',

    ['<C-space>'] = { 'show', 'show_documentation', 'hide_documentation' },

    ['<C-p>'] = { 'select_prev', 'fallback' },
    ['<C-n>'] = { 'select_next', 'fallback' },
    ['<C-b>'] = { 'scroll_documentation_up', 'fallback' },
    ['<C-f>'] = { 'scroll_documentation_down', 'fallback' },
  },
  signature = {
    enabled = true,
  },

  completion = {
    accept = { auto_brackets = { enabled = false }, },
    documentation = { auto_show = true, auto_show_delay_ms = 500 },
    ghost_text = { enabled = true },
  },

  sources = {
    default = { "lsp", "path", "snippets", "buffer" },

    -- Disable cmdline completions
    cmdline = {},
  },

})
