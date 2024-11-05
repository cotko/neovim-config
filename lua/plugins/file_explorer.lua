local api = require('nvim-tree.api')
local uv = require('luv')
local resizeStep = 10
local size = 40

local canOpen = vim.api.nvim_win_get_width(0) > 40

local function resize(wider)
  local new_size = '+' .. resizeStep
  if not wider then new_size = '-' .. resizeStep end
  vim.cmd('NvimTreeResize' .. new_size)
end

local function on_attach(bufnr)

  local function opts(desc)
    return {
      desc = 'nvim-tree: ' .. desc,
      buffer = bufnr,
      noremap = true,
      silent = true,
      nowait = true
    }
  end

  local function kmset(keymap, cb, desc)
    vim.keymap.set('n', keymap, cb, opts(desc))
  end

  local function copy(node)
    if FNS.file.better_copy(node) == 'is_folder' then
      vim.notify(
        'Cannot copy: only files supported.\nI Used "mC" instead:\n use "mp" to paste\nuse "mC" to clear',
        2
      )
      api.fs.copy.node(node)
    end
  end

  local function get_root(node)
    node = FNS.util.nvim_tree_get_node(node)
    if not node then return end

    local path = node.absolute_path or uv.cwd()
    if node.type ~= 'directory' and node.parent then
      path = node.parent.absolute_path
    end

    return path
  end

  local function live_grep_in_folder(node)
    local path = get_root(node)
    require('telescope.builtin').live_grep({
      search_dirs = { path },
      prompt_title = string.format(
        'Grep in [%s]', vim.fs.basename(path)),
    })
  end

  local function egrep_in_folder(node)
    local path = get_root(node)
    require('telescope').extensions.egrepify.egrepify({
      -- cwd = path,
      search_dirs = { path },
      prompt_title = string.format(
        'Grep in [%s]', vim.fs.basename(path)),
    })
  end

  kmset('cd', api.tree.change_root_to_node,
    'cd in the directory under the cursor')

  kmset('o', api.node.open.no_window_picker,
    'edit file / toggle  folder')

  kmset('<CR>', api.node.open.edit,
    'edit with window picker')

  kmset('T', api.node.open.tab,
    'open the file in a new tab')

  kmset('<Tab>', api.node.open.preview,
    'open the file as a preview (keeps the cursor in the tree)')

  kmset('>', api.node.navigate.sibling.next,
    'navigate to the next sibling of current file/directory')

  kmset('<', api.node.navigate.sibling.prev,
    'navigate to the prev sibling of current file/directory')

  kmset('p', api.node.navigate.parent,
    'move cursor to the parent directory')

  kmset('P', api.node.navigate.parent_close,
    'close current opened directory or parent')

  kmset('H', api.tree.toggle_hidden_filter,
    'toggle visibility of dotfiles via |filters.dotfiles| option')

  kmset('I', api.tree.toggle_gitignore_filter,
    'toggle visibility of files/folders hidden via |git.ignore| option')

  kmset('ma',api.fs.create,
    'add a file; leaving a trailing `/` will add a directory')

  kmset('md',api.fs.remove,
    'delete a file (will prompt for confirmation)')

  kmset('mD',api.fs.trash,
    'trash a file via |trash| option')

  kmset('mr',api.fs.rename, 'rename a file')
  kmset('mm',api.fs.rename, 'rename a file')
  kmset('mc',copy, 'copy file (better copy)')

  kmset('mR',api.fs.rename_sub,
    'rename a file and omit the filename on input')

  kmset('mx',api.fs.cut,
    'add/remove file/directory to cut clipboard')

  kmset('mC',api.fs.copy.node,
    'add/remove file/directory to copy clipboard')

  kmset('mp',api.fs.paste,
    'paste from clipboard; cut clipboard has precedence over copy; will prompt for confirmation')


  kmset('yy',api.fs.copy.filename, 'copy name to system clipboard')
  kmset('ya',api.fs.copy.absolute_path,
    'copy absolute path to system clipboard')


  kmset('ec',api.tree.collapse_all, 'collapse the whole tree')
  kmset('ea',api.tree.expand_all,
    'expand the whole tree, stopping after expanding')

  kmset('=', function () resize(true) end, 'resize up')
  kmset('+', function () resize(true) end, 'resize up')
  kmset('-', function () resize(false) end, 'resize down')

  kmset('.', api.node.run.cmd,
    'enter vim command mode with the file the cursor is on')

  kmset('r', api.tree.reload, 'refresh the tree')
  kmset('R', api.tree.reload, 'refresh the tree')
  kmset('q', api.tree.close,  'close tree window')
  kmset('<S-k>', api.node.show_info_popup,
    'toggle a popup with file infos')

  kmset('<c-f>', egrep_in_folder,
    'Telescope egrepify in this folder')

  kmset('<s-f>', live_grep_in_folder,
    'Telescope live_grep in this folder')

  kmset('<BS>', api.tree.change_root_to_parent, 'go back/up one folder')
  kmset('?', api.tree.toggle_help, 'toggle help')
  kmset('gx',api.node.run.system,
    'open a file with default system application')


end

vim.api.nvim_create_autocmd('User', {
  pattern = 'WorkspacesLoaded',
  callback = function()
    if not canOpen then return end
    api.tree.open()
  end
})



require('nvim-tree').setup({
  on_attach = on_attach,

  -- keeps the cursor on the first letter of the 
  -- filename when moving in the tree.
  hijack_cursor = true,

  disable_netrw = true,
  hijack_netrw = true,

  sync_root_with_cwd = true,

  -- Use |vim.ui.select| style prompts.
  -- Necessary when using a UI prompt decorator
  -- such as dressing.nvim or telescope-ui-select.nvim
  select_prompts = true,

  filters = {
    dotfiles = true,
  },

  view = {
    centralize_selection = false,
    width = size,
    number = true,
    relativenumber = true,
    signcolumn = 'yes',
    cursorline = true,
  },

  git = {
    enable = true,
    ignore = false,
  },

  renderer = {
    root_folder_label = false,
    highlight_git = 'all',
    indent_markers = { enable = true },
    icons = {
      glyphs = {
        default = '󰈚',
        folder = {
          default = '',
          empty = '',
          empty_open = '',
          open = '',
          symlink = '',
        },
        git = { unmerged = '' },
      },
    },
  },

  diagnostics = {
    enable = true,
    show_on_dirs = true,
    show_on_open_dirs = true,
    debounce_delay = 50,
    severity = {
      min = vim.diagnostic.severity.HINT,
      max = vim.diagnostic.severity.ERROR,
    },
    icons = {
      hint = '',
      info = '',
      warning = '',
      error = '',
    },
  },

  update_focused_file = {
    -- disable annoying file focusing when
    -- related buffer is focuced
    enable = false,
    -- Update the root directory of the tree if the file is
    -- not under current root directory.
    update_root = false,
  },

  actions = {
    change_dir = {
      -- change directory globally to what is 
      -- changed to within the tree
      enable = true,
      global = true,
    },
  },
})
