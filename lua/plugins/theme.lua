vim.cmd('colorscheme ' .. ColorScheme)

-- TODO: select proper colorscheme
-- like 3rd from https://github.com/NvChad/ui/tree/v3.0


-- TODO: try out nvchad ui


FNS.util.alduinColorschemeNvimPane = function()
  if vim.g.colors_name ~= 'alduin' then return end

  -- change bg color for tree pane
  vim.cmd([[
      :hi      NvimTreeNormal         guibg=#272727
      :hi      NvimTreeFolderIcon     guibg=#272727
      :hi      NvimTreeGitDeletedIcon guibg=#272727
      :hi      NvimTreeGitDirtyIcon   guibg=#272727
      :hi      NvimTreeGitIgnoredIcon guibg=#272727
      :hi      NvimTreeGitMergeIcon   guibg=#272727
      :hi      NvimTreeGitNewIcon     guibg=#272727
      :hi      NvimTreeGitRenamedIcon guibg=#272727
      :hi      NvimTreeGitStagedIcon  guibg=#272727
  ]])
end

if vim.g.colors_name ~= 'onedark' then
  require('onedark').setup({
    style = 'warm',
    transparent = false,
    ending_tildes = true,
    -- toggle_style_key = '<leader>tt',
    toggle_style_key = nil,
    -- toggle_style_list = {
    --  'dark', 'darker', 'cool', 'deep', 'warm', 'warmer', 'light'
    -- },
    -- toggle_style_list = { 'dark', 'warm', 'light' },
    toggle_style_list = {},
  })
end

local function set_telescope_highlights()
vim.cmd([[
  " Telescope Normal background and foreground (slightly lighter)
  highlight TelescopeNormal guibg=#2F333B guifg=#AFB7C6

  " Telescope Border (slightly lighter)
  highlight TelescopeBorder guibg=#2F333B guifg=#3B404B

  " Telescope Prompt
  highlight TelescopePromptNormal guibg=#343840 guifg=#AFB7C6
  highlight TelescopePromptBorder guibg=#343840 guifg=#3B404B
  highlight TelescopePromptTitle guibg=#DBA470 guifg=#2F333B

  " Telescope Results
  highlight TelescopeResultsNormal guibg=#2F333B guifg=#AFB7C6
  highlight TelescopeResultsBorder guibg=#2F333B guifg=#3B404B
  highlight TelescopeResultsTitle guibg=#2F333B guifg=#2F333B

  " Telescope Preview
  highlight TelescopePreviewNormal guibg=#30343A guifg=#AFB7C6
  highlight TelescopePreviewBorder guibg=#30343A guifg=#3B404B
  highlight TelescopePreviewTitle guibg=#DBA470 guifg=#2F333B

  " Customize selection and matching
  highlight TelescopeSelection guibg=#343840 guifg=#AFB7C6
  highlight TelescopeSelectionCaret guibg=#343840 guifg=#EFCA85
  highlight TelescopeMultiSelection guibg=#343840 guifg=#AFB7C6
  highlight TelescopeMatching guifg=#EFCA85
]])

end

vim.api.nvim_create_autocmd('User', {
  group = AuGroup,
  pattern = 'TelescopePreviewerLoaded',
  callback = function()
    set_telescope_highlights()
  end,
})
