require('gitsigns').setup({
  signs = {
    add = { text = '+' },
    change = { text = '~' },
    delete = { text = '󰍵' },
    topdelete = { text = '‾' },
    changedelete = { text = '󱕖' },
  },
  signcolumn = true, -- Toggle with `:Gitsigns toggle_signs`
  numhl = true, -- Toggle with `:Gitsigns toggle_numhl`
  linehl = false, -- Toggle with `:Gitsigns toggle_linehl`
  word_diff = false, -- Toggle with `:Gitsigns toggle_word_diff`
  attach_to_untracked = true,
  current_line_blame = true, -- Toggle with `:Gitsigns toggle_current_line_blame`
  -- TODO:
  -- on_attach = function(buffnr)
  --   local gs = package.loaded.gitsigns

  --   local function map(mode, key, cb, desc)
  --     FN.misc.map(mode, key, cb, desc, { desc = desc, buffer = buffnr })
  --   end

  --   -- Navigation
  --   map('n', ']c', function()
  --     gs.nav_hunk('next')
  --   end, '[git] Next Hunk')
  --   map('n', '[c', function()
  --     gs.nav_hunk('prev')
  --   end, '[git] Prev Hunk')
  --   map('n', ']C', function()
  --     gs.nav_hunk('last')
  --   end, '[git] Last Hunk')
  --   map('n', '[C', function()
  --     gs.nav_hunk('first')
  --   end, '[git] First Hunk')

  --   -- Actions
  --   map({ 'n', 'v' }, '<leader>ghs', ':Gitsigns stage_hunk<CR>', '[git] stage hunk')
  --   map({ 'n', 'v' }, '<leader>ghr', ':Gitsigns reset_hunk<CR>', '[git] reset hunk')
  --   map('n', '<leader>ghS', gs.stage_buffer, '[git] stage buffer')
  --   map('n', '<leader>ghu', gs.undo_stage_hunk, '[git] undo stage hunk')
  --   map('n', '<leader>ghR', gs.reset_buffer, '[git] reset buffer')
  --   map('n', '<leader>ghp', gs.preview_hunk_inline, '[git] preview hunk inline')
  --   map('n', '<leader>ghb', function()
  --     gs.blame_line({ full = true })
  --   end, '[git] blame line')
  --   map('n', '<leader>ghd', gs.diffthis, '[git] diff this')
  --   map('n', '<leader>ghD', function()
  --     gs.diffthis('~')
  --   end, '[git] diff this ~')
  --   map('n', '<leader>gtd', gs.toggle_deleted, '[git] toggle deleted')
  --   map('n', '<leader>gtb', gs.toggle_current_line_blame, '[git] toggle current line blame')

  --   -- Text object
  --   map({ 'o', 'x' }, 'gih', ':<C-U>Gitsigns select_hunk<CR>', '[git] select hunk')
  -- end,

})
