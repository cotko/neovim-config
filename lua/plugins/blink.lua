if CompletionModule ~= 'blink' then
  return
end

-- fallbacks are needet so blink does not eat up keys like "tab" etc
require('blink.cmp').setup({
  keymap = {
    ['<Tab>'] = { 'select_and_accept', 'fallback' },
    -- ['<Tab>'] = 'accept',

    ['<C-space>'] = { 'show', 'show_documentation', 'hide_documentation' },

    ['<C-p>'] = { 'select_prev', 'fallback' },
    ['<C-n>'] = { 'select_next', 'fallback' },
  },
  trigger = {
    signature_help = {
      enabled = true,
    }
  }
})
