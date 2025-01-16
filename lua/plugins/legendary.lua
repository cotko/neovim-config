local tbuiltin = require('telescope.builtin')
local legendary = require('legendary')
local lFilters = require('legendary.filters')

local function lkmpm(mode, map, cmd, desc, opts)
  local kmap = {
    map,
    cmd,
    description = desc,
  }
  if opts ~= nil then kmap.opts = opts end
  if mode ~= nil then kmap.mode = mode end

  return kmap
end

local function lkmp(map, cmd, desc, opts)
  return lkmpm(nil, map, cmd, desc, opts)
end

local function taggedLkmp(tag)
  return function(map, cmd, desc, opts, mode)
    return lkmpm(mode, map, cmd, tag .. ': ' .. desc, opts)
  end
end

local tLkmp = taggedLkmp('Telescope')


legendary.setup({
  include_builtin = false,
  include_legendary_cmds = false,
  keymaps = {
    lkmp('<leader><tab>', '<cmd> NvimTreeToggle <CR>',
      'Toggle file explorer'),
    lkmp('<a-e>', '<cmd> NvimTreeFocus <CR>',
      'Focus file explorer'),

    -- switch between windows and buffers
    lkmp('<a-h>', '<c-w>h', ' window left'),
    lkmp('<a-l>', '<c-w>l', ' window right'),
    lkmp('<a-j>', '<c-w>j', ' window down'),
    lkmp('<a-k>', '<c-w>k', ' window up'),

    -- [
    --   Remap for dealing with word wrap
    --   also don't use g[j|k] when in operator pending mode,
    --   so it doesn't alter d, y or c behaviour
    -- ]
    -- keep normal behaviour with CTRL-k
    lkmp('<c-j>', 'j', 'normal down move'),
    lkmp('<c-k>', 'k', 'normal up move'),
    lkmp(
      'k',
      'v:count || mode(1)[0:1] == "no" ? "k" : "gk"',
      'move up in wordwrap',
      { expr = true, silent = true }
    ),
    lkmp(
      'j',
      'v:count || mode(1)[0:1] == "no" ? "j" : "gj"',
      'move down in wordwrap',
      { expr = true, silent = true }
    ),

    -- keep cursor centered when moving
    lkmp('<C-d>', '<C-d>zz', 'keep cursor centered'),
    lkmp('<C-u>', '<C-u>zz', 'keep cursor centered'),

    -- go to end of word and enter insert mode
    lkmp('e', 'ea', 'go to end of wrod + into insert mode'),
    lkmp('<leader>d', '<cmd>lua MiniBufremove.delete(nil, true)<CR>',
      'close + delete the buffer'),

    -- Diagnostic
    lkmp('<leader>e', vim.diagnostic.open_float,
      'diagnostic float'),
    lkmp('<leader>l', vim.diagnostic.setloclist,
      'diagnostic loc list'),

    -- TODO:
    -- 'Zoom' in/out
    -- lkmp('<C-=>', function() FN.font.adjustFontSize(1) end,
    --   '=  increase font size'),
    -- lkmp('<C-+>', function() FN.font.adjustFontSize(1) end,
    --   '+  increase font size'),
    -- lkmp('<C-->', function() FN.font.adjustFontSize(-1) end,
    --   '+  decrease font size'),
    -- lkmp(
    --   '<C-0>',
    --   function() FN.font.adjustFontSize(0, true) end,
    --   '+  reset font size'
    -- ),

    -- TODO: json parse/compact etc

    -- misc
    lkmp('<C-s>', '<cmd> w <CR>', 'save file'),
    lkmp('<C-y>', '<cmd> %y+ <CR>', 'yank whole file'),

    -- insert from * register for all modes
    lkmp('<insert>', '"*p', 'insert content from *'),
    lkmpm({ 'v' }, '<insert>', '"_c<C-R>*<Esc>', 'insert content from *'),
    lkmpm({ 'i', 'c' }, '<insert>', '<C-R>*', 'insert content from *'),

    lkmp('<ESC>', '<cmd> noh <CR>', 'no highlight'),
    lkmp('<leader>g', '<cmd> :e# <CR>', 'goto prev buffer'),

    lkmp('<F2>', FNS.util.toggleIgnoreCase,
      'toggle ignore case'
    ),

    lkmp('<F3>', ':echo expand("%:p")<CR>',
      'show file location'),
    lkmp('<F4>', FNS.util.toggleHlSearch, 'toggle highlight'),
    lkmp('<F9>', FNS.util.toggleIndents,
      'toggle between indenting'),
    lkmp('<F11>', FNS.util.toggleLineNumbering,
      'toggle line numbering'),
    lkmp('<F7>', vim.cmd.UndotreeToggle, 'toggle undo tree'),


    -- apply common macros
    lkmp('<leader>q', '@q', 'Quickly apply macro q'),
    lkmp('<leader>m', '@q', 'Quickly apply macro m'),

    -- do not jump on asterisk
    lkmp('*', 'm`<cmd>keepjumps normal! *``<CR><cmd>set hls<CR>',
      'Don\'t jump on first * -- simpler vim-asterisk'),

    -- do not yank empty deleted lines
    lkmp('dd',
      function()
        if vim.api.nvim_get_current_line():match('^%s*$') then
          return '"_dd'
        else
        return 'dd'
        end
      end,
      'Smart dd, don\'t yank empty lines',
      { expr = true }
    ),

    -- treesj toggle
    lkmp('gs', '<cmd>TSJToggle<CR>', 'treesj toggle'),

    lkmp('gss', '<cmd>TSJFormatExpand<CR>',
      'treesj expand recursive'),

    -- Telescope stuff
    tLkmp('<leader>t', '<cmd>Telescope<CR>', 'Open telescope'),
    tLkmp('<leader>b', '<cmd>Telescope resume<CR>',
      'Open last telescope query',
      nil,
      {'n', 'i' }),
    tLkmp(
      '<leader><leader>',
      '<cmd>Telescope buffers sort_mru=true sort_lastused=true initial_mode=normal<CR>',
      '[ ] Find existing buffers (MRU)'
    ),
    tLkmp('<leader>:', '<cmd>Telescope command_history initial_mode=normal<cr>',
      'Command History'),

    tLkmp('<leader>r', '<cmd>Telescope oldfiles initial_mode=normal<cr>',
      '[F]ind [R]ecent Files'),

    tLkmp('<leader>fg', tbuiltin.live_grep,
      'Live Grep'),

    tLkmp('<leader>sg', '<cmd>Telescope egrepify<CR>',
      'Grep using egrepify'),

    tLkmp('<leader>ff', tbuiltin.find_files,
      'Find Files (Root Dir)'
    ),

    lkmp('<leader>ss',
      function()
        require('spectre').toggle()
      end,
      'Search (Spectre)'
    ),

    lkmp(
      '<leader>sw',
      function()
        require('spectre').open_visual({ select_word = true })
      end,
      'Search current word (Spectre)'
    ),

    lkmpm({ 'v' }, '<leader>sw',
      function()
        require('spectre').open_visual()
      end,
      'Search current word (Spectre)'
    ),

    lkmp(
      '<leader>sp',
      function()
        require('spectre').open_file_search({ select_word = true })
      end,
      'Search on current file (Spectre)'
    ),

    tLkmp('<leader>p',
      function()
        vim.cmd('WorkspacesOpen')
        -- got to normal mode, I ussually use MRU project..
        vim.schedule(function() vim.cmd('stopinsert') end)
      end,
      'Sessions / Projects'
    ),

    -- Legendary
    lkmp('<leader>c',
      function()
        legendary.find({
          filters = lFilters.OR(
            lFilters.funcs(),
            lFilters.commands()
          )
        })
      end,
      'Legendary: Command & Functions palette'),

    lkmp('<leader>lr', '<cmd>LegendaryRepeat<CR>',
      'Legendary: repeat last action'),
    lkmp('<space>r', '<cmd>LegendaryRepeat<CR>',
      'Legendary: repeat last action'),

    -- vessel
    lkmp('gm', '<cmd>Marks<CR>', 'View marks'),
    lkmp('gj', '<cmd>Jumps<CR>', 'View jumps'),

  },
  autocmds = {
    {
      name = AuGroup,
      clear = true,
      {
        { 'ColorScheme', 'User' },
        FNS.util.alduinColorschemeNvimPane,
        opts = {
          pattern = { 'alduin', 'SetupComplete' },
        },
        description = 'Changes NvimTree pane bg color in case of alduin colorscheme'
      },
      {
        { 'TextYankPost' },
        function()
          vim.highlight.on_yank({
            higroup = 'IncSearch',
            timeout = 120,
          })
        end,
        opts = {
          pattern = '*'
        },
      }
    },
  },
  extensions = {
  },

  commands = {
    -- Workspaces
    {
      itemgroup = 'Workspaces',
      commands = {
        {
          ':WorkspacesAdd',
          function()
            local workspaces = require('workspaces')
            local cwd = FNS.util.get_project_root()
            local suggested_name = cwd:gsub('.*%/', '')

            vim.ui.input(
              {
                prompt = 'Name workspace',
                default = suggested_name,
              },
              function(name)
                if name == nil then return end
                workspaces.add(cwd, name)
              end
            )
          end,
          description = 'Workspaces: Add a new workspace',
        },
        {
          ':WorkspacesRemove',
          description = 'Workspaces: Remove a workspace',
        },
        {
          ':WorkspacesRename',
          function()
            local workspaces = require('workspaces')
            local current_name = workspaces.name()
            if current_name == nil then
              vim.notify('Not in a workspace', 3)
              return
            end

            vim.ui.input(
              {
                prompt = 'Rename workspace to',
                default = current_name,
              },
              function(new_name)
                if new_name == nil then return end
                workspaces.rename(current_name, new_name)
              end
            )
          end,
          description = 'Workspaces: Rename a workspace',
        },
        {
          ':WorkspacesList',
          description = 'Workspaces: List all workspaces',
        },
        {
          ':WorkspacesLoad',
          description = 'Workspaces: Load a workspace',
        },
        {
          ':WorkspacesOpen',
          description = 'Workspaces: Open a workspace in a new tab',
        },
      }
    },

    -- TSJ split/join (expand/collapse)
    {
      itemgroup = 'Format',
      commands = {
        {
          ':Format',
          function()
            vim.lsp.buf.format()
          end,
          description = 'Format the code using LSP',
        },
        {
          ':FormatBiome',
          function()
            vim.lsp.buf.format({
              filter = function(client)
                return client.name == 'biome'
              end
            })
          end,
          description = 'Format the code using biome',
        },
        {
          ':FormatNullLs',
          function()
            vim.lsp.buf.format({
              filter = function(client)
                return client.name == 'null-ls'
              end
            })
          end,
          description = 'Format the code using null-ls',
        },
        {
          ':TSJToggle',
          function()
            require('treesj').toggle({ split = { recursive = true } })
          end,
          description = 'toggle node under cursor (expand/collapse)',
        },
        {
          ':TSJFormatExpand',
          function()
            local treejs = require('treesj')
            treejs.join({})
            treejs.toggle({split = {recursive = true}})
          end,
          description = 'uses join and then recursive split to format the code',
        },
        {
          ':TSJSplitRecursive',
          function()
            require('treesj').split({split = {recursive = true}})
          end,
          description = 'expand recursive node under cursor',
        },
        {
          ':TSJSplit',
          description = 'expand node under cursor',
        },
        {
          ':TSJJoin',
          description = 'collapse node under cursor',
        },
      },
    },

    -- Update deps etc
    {
      itemgroup = 'Update modules',
      commands = {
        {
          ':NvimUpdate',
          function()
            vim.cmd('MasonToolsUpdate')
            vim.cmd('DepsUpdate')
          end,
          description = 'update mini deps, mason',
        },
        {
          ':DepsUpdate',
          function()
            vim.cmd(':DepsUpdate cwd=' .. FNS.util.get_project_root())
          end,
          description = 'update mini deps',
        },
      }
    },

    -- TODO module stuff
    {
      itemgroup = 'TODO keywords',
      commands = {
        {
          ':TodoTelescope',
          function()
            vim.cmd(':TodoTelescope cwd=' .. FNS.util.get_project_root())
          end,
          description = 'TODO: find using telescope',
        },
        {
          ':TodoQuickFix',
          function()
            vim.cmd(':TodoQuickFix cwd=' .. FNS.util.get_project_root())
          end,
          description = 'TODO: show in quick fix',
        },
        {
          ':TodoLocList',
          function()
            vim.cmd(':TodoLocList cwd=' .. FNS.util.get_project_root())
          end,
          description = 'TODO: show in loc list',
        },
      },
    },

    -- TS module
    {
      itemgroup = 'TS server utils',
      commands = {
        {
          ':TSToolsOrganizeImports',
          description = 'Typescript: sorts and removes unused imports',
          itemgroup = 'Typescript',
        },
        {
          ':TSToolsSortImports',
          description = 'Typescript: sorts imports',
          itemgroup = 'Typescript',
        },
        {
          ':TSToolsRemoveUnusedImports',
          description = 'Typescript: removes unused imports',
          itemgroup = 'Typescript',
        },
        {
          ':TSToolsRemoveUnused',
          description = 'Typescript: removes all unused statements',
          itemgroup = 'Typescript',
        },
        {
          ':TSToolsAddMissingImports',
          description = 'Typescript: adds imports for all statements that lack one and can be imported',
        },
        {
          ':TSToolsFixAll',
          description = 'Typescript: fixes all fixable errors',
        },
        {
          ':TSToolsGoToSourceDefinition',
          description = 'Typescript: goes to source definition (available since TS v4.7)',
        },
        {
          ':TSToolsRenameFile',
          description = 'Typescript: allow to rename current file and apply changes to connected files',
        },
        {
          ':TSToolsFileReferences',
          description = 'Typescript: find files that reference the current file (available since TS v4.2)',
        },
      },
    },
    {
      itemgroup = 'LSP',
      commands = {
        {
          'LspToggler',
          description = 'Opens a toggler for LSPs',
        },
        {
          'LspLensToggle',
          description = 'Toggles LSP lens',
        },
        {
          'InspectLSP',
          FNS.util.inspect_lsp_client,
          description = 'Prompts for LSP client and then prints its config',
        },
        {
          'BiomeNlsFormatterToggle',
          description = 'Toggle Biome NLS formatter',
        }
      },
    },
    {
      itemgroup = 'Marks / Jumps',
      commands = {
        {
          'MarksDeleteAll',
          function()
            vim.cmd('delmarks A-Z0-9')
            vim.cmd('delm!')
          end,
          description = 'Delete all marks',
        },
        {
          'MarksDeleteGlobal',
          function()
            vim.cmd('delmarks A-Z0-9')
          end,
          description = 'Delete global marks',
        },
        {
          'MarksDeleteLocal',
          function()
            vim.cmd('delm!')
          end,
          description = 'Delete local marks',
        },
        {
          'JumpsDelete',
          function()
            vim.cmd('clear')
          end,
          description = 'Delete all jumps',
        }
      },
    },
    {
      'RenderMarkdownToggle',
      function()
        require('render-markdown').toggle()
      end,
      description = 'Enable this plugin',
    },
    {
      'KubeCtl',
      function()
        require('kubectl').toggle()
      end,
      description = 'Toggles kubectl',
    },
    {
      'KubeCtx',
      description = 'Choose kubernetes instance',
    },
    {
      'GG',
      function()
        local path = FNS.util.get_buffer_file_parent()
          or FNS.util.get_project_root()
        os.execute('cd ' .. path .. ' && gh browse &>/dev/null')
      end,
      description = 'Open current git repo (gh browse)',
    },
    {
      'GrugFar',
      description = 'Search/Find and Replace (grug-far)',
    },
    {
      'Spectre',
      description = 'Search/Find and Replace (spectre)',
    }
  },
})
