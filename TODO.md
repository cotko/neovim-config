# grep stuff

https://www.reddit.com/r/neovim/comments/xj784v/telescope_live_grep_inside_certain_folders/

how to search in custom dirs + udpate dirs on the fly  
author of this comment apparently has cool dotfiles:  
https://github.com/JoosepAlviste/dotfiles/blob/master/config/nvim/lua/j/telescope_pretty_pickers.lua

# other plugins

completion plugins
nvchad UI

TODO comments - better path display
ask chatgpt this:

> how would I change display function of extendsion for telescope, like for folke/todo-comments.nvim?
> I'd like it to pick up default settings from defaults.path_display but it appears it does not

- https://github.com/DNLHC/glance.nvim
- https://github.com/jinzhongjia/LspUI.nvim - cekn tole ce je ok

spectre
https://github.com/nvim-pack/nvim-spectre

GrugFar instead of sectre?
https://github.com/MagicDuck/grug-far.nvim

-- -- Formatting
-- later(function()
-- add('stevearc/conform.nvim')
-- source('plugins/conform.lua')
-- end)

-- cool; quickly applies macro (should switch from qm to qq)
map("n", "<Leader>q", "@q", { desc = "Quickly apply macro q" })

-- seems cool; don't jump on * , just highlight
https://stackoverflow.com/questions/4256697/vim-search-and-highlight-but-do-not-jump#comment91750564_4257175
```
map(
  "n",
  "*",
  "m`<Cmd>keepjumps normal! *``<CR>",
  { desc = "Don't jump on first * -- simpler vim-asterisk" }
)
```

```
map("n", "dd", function()
    if vim.api.nvim_get_current_line():match("^%s\*$") then
    return '"\_dd'
    else
    return "dd"
    end
end, { desc = "Smart dd, don't yank empty lines", expr = true })

```

-- code action

```
  map("n", "<Leader><Leader>", function()
    if dkosettings.get("lsp.code_action") == "tiny-code-action" then
      if code_action.tca() or code_action.ap() then
        return
      end
    elseif code_action.ap() or code_action.tca() then
      return
    end
    vim.lsp.buf.code_action()
  end, lsp_opts({ desc = "LSP Code Action" }))
```

Find a solution to do this:

```
/foo/bar/awer.waerrerge wer /awerkjwart/
            ^ how to replace text between this / and / ?
```

-- check `various-textobjs`

```
{ 1,2,45}
```


SE TO:
 - supermaven/codeium se tepeta - ce se en disabla mora delat completion od enablanga
  - zaenkrat ok, popravit moram da sam napaberkujem completione in jih skupno izrisem
 - ce odprem diffview / undotree mora <alt+e> skocit na pane od enga od teh dveh, naemsto v file tree
