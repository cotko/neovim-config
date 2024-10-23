if CompletionModule ~= 'blink' then
  return
end

require("blink.cmp").setup({
  keymap = {
    accept = { '<Tab>' },
    show = { '<C-space>', '<C-p>' },
  },
  trigger = {
    signature_help = {
      enabled = true,
    }
  }
})
