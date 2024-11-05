local path_package = vim.fn.stdpath('data') .. '/site/'
local mini_path = path_package .. 'pack/deps/start/mini.deps'

if not vim.loop.fs_stat(mini_path) then
  print('Installing `mini.deps`')
  local clone_cmd = {
    'git', 'clone', '--filter=blob:none',
    'https://github.com/echasnovski/mini.deps', mini_path
  }
  vim.fn.system(clone_cmd)
  vim.cmd('packadd mini.deps | helptags ALL')
  print('Installed `mini.deps`')
end

-- set up 'mini.deps' (customize to your liking)
require('mini.deps').setup({
  path = {
    package = path_package
  }
})

-- use 'mini.deps'. `now()` and `later()` are helpers for a 
-- safe two-stage startup and are optional.
local add, now, later = MiniDeps.add, MiniDeps.now, MiniDeps.later
local setupPlugin = function(path) dofile(PluginSource .. path) end

now(function()
  add({ source = 'echasnovski/mini.deps', })

  -- Notifications
  add('j-hui/fidget.nvim')
  setupPlugin('fidget.lua')

  -- Theme
  add({ source = 'navarasu/onedark.nvim', })
  add({ source = 'RRethy/base16-nvim', })
  add({ source = 'bakageddy/alduin.nvim', })
  add({ source = 'shaunsingh/nord.nvim' })
  add({
    source = 'zenbones-theme/zenbones.nvim',
    depends = {
      'rktjmp/lush.nvim',
    },
  })
  setupPlugin('theme.lua')

  -- Telescope
  local function build_fzf(params)
    vim.notify('Building fzf native', vim.log.levels.INFO)
    local obj = vim.system({ 'make' }, { cwd = params.path }):wait()

    if obj.code == 0 then
      vim.notify('Building fzf native done', vim.log.levels.INFO)
    else
      vim.notify('Building fzf native failed', vim.log.levels.ERROR)
    end
  end

  add({
    source = 'natecraddock/workspaces.nvim',
  })
  setupPlugin('workspaces.lua')

  add({
    source = 'nvim-telescope/telescope.nvim',
    depends = {
      'nvim-lua/plenary.nvim',
      'stevearc/dressing.nvim',
      'debugloop/telescope-undo.nvim',
      'nvim-telescope/telescope-ui-select.nvim',
      'fdschmidt93/telescope-egrepify.nvim',
      {
        source = 'nvim-telescope/telescope-fzf-native.nvim',
        hooks = {
          post_install = build_fzf,
          post_checkout = build_fzf,
        },
      }
    },
  })
  setupPlugin('telescope.lua')

  -- Legendary; command pallete, keymaps etc
  add({
    source = 'mrjones2014/legendary.nvim',
    -- frenecy sorting support
    depends = { 'kkharji/sqlite.lua'}
  })
  setupPlugin('legendary.lua')

  -- LSP & stuff
  add({
    source = 'nvim-treesitter/nvim-treesitter-textobjects',
    depends = {{
      source = 'nvim-treesitter/nvim-treesitter',
      checkout = 'master',
      hooks = {
        post_checkout = function() vim.cmd('TSUpdate') end
      },
    }}
  })
  setupPlugin('treesitter.lua')

  -- completion plugins
  add('ms-jpq/coq_nvim')

  local function build_blink(params)
    vim.notify('Building blink.cmp', vim.log.levels.INFO)
    local obj = vim.system(
      { 'cargo', 'build', '--release' },
      { cwd = params.path }
    ):wait()

    if obj.code == 0 then
      vim.notify('Building blink.cmp done', vim.log.levels.INFO)
    else
      vim.notify('Building blink.cmp failed', vim.log.levels.ERROR)
    end
  end

  add({
    source = 'saghen/blink.cmp',
    depends = {
      'rafamadriz/friendly-snippets',
    },
    hooks = {
      post_install = build_blink,
      post_checkout = build_blink,
    }
  })

  add({
    source = 'neovim/nvim-lspconfig',
    depends = {
      'williamboman/mason.nvim',
      'mrjones2014/legendary.nvim',
      'williamboman/mason-lspconfig.nvim',
      'WhoIsSethDaniel/mason-tool-installer.nvim',
    }
  })

  add({
		source = 'pmizio/typescript-tools.nvim',
    depends = {
      'nvim-lua/plenary.nvim',
      'neovim/nvim-lspconfig',
    }
  })

  add({
		source = 'nvim-java/nvim-java',
    depends = {
      'nvim-java/lua-async-await',
      'nvim-java/nvim-java-refactor',
      'nvim-java/nvim-java-core',
      'nvim-java/nvim-java-test',
      'nvim-java/nvim-java-dap',
      'MunifTanjim/nui.nvim',
      'neovim/nvim-lspconfig',
      'mfussenegger/nvim-dap',
    }
  })

  add({
    source = 'mfussenegger/nvim-dap',
    depends = {
      -- Creates a beautiful debugger UI
      'rcarriga/nvim-dap-ui',

      -- Required dependency for nvim-dap-ui
      'nvim-neotest/nvim-nio',

      -- Installs the debug adapters for you
      'williamboman/mason.nvim',
      'jay-babu/mason-nvim-dap.nvim',

      -- Add your own debuggers here
      --'leoluz/nvim-dap-go',
    }
  })

  setupPlugin('debug.lua')
  setupPlugin('lsp.lua')
end)

-- GIT
later(function()
  add({
	  source = 'lewis6991/gitsigns.nvim',
  })
  setupPlugin('gitsigns.lua')
end)

later(function()
  add({
    source = 'NeogitOrg/neogit',
    depends = {
      'nvim-lua/plenary.nvim',
      'sindrets/diffview.nvim',
      'nvim-telescope/telescope.nvim',
    },
  })
  require('neogit').setup({})
end)

-- File explorer
later(function()
  add({
    source = 'nvim-tree/nvim-tree.lua',
    depends = { 'nvim-tree/nvim-web-devicons' },
  })
  setupPlugin('file_explorer.lua')
end)
later(function()
  add({
    source = 'stevearc/oil.nvim',
    depends = { 'nvim-tree/nvim-web-devicons' },
  })
  require('oil').setup({
    delete_to_trash = true,
    keymaps = {
      ['cd'] = { 'actions.cd', opts = { scope = 'tab' }, desc = ':tcd to the current oil directory', mode = 'n' },
      ['gx'] = 'actions.open_external',
      ['H'] = 'actions.toggle_hidden',
    },
  })
end)

-- Util
later(function()
  add({
	  source = 'echasnovski/mini.bufremove',
  })
  require('mini.bufremove').setup({})
end)

later(function()
  add({
	  source = 'mbbill/undotree',
  })
end)

later(function()
  add('gcmt/vessel.nvim')
  require('vessel').setup({
    create_commands = true,
    commands = { -- not required unless you want to customize each command name
    view_marks = 'Marks',
    view_jumps = 'Jumps',
    view_buffers = 'Buffers'
    }
})
end)

later(function()
  add('meznaric/key-analyzer.nvim')
  require('key-analyzer').setup({})
end)


-- Expand/collapse (join/split) code blocks (also JSON etc)
later(function()
  add('Wansmer/treesj')
  require('treesj').setup({
    max_join_length = 9999999
  })
end)

-- TODO, FIXME, HACK etc comments
later(function()
  add({
    source = 'folke/todo-comments.nvim',
    depends = {
      'nvim-lua/plenary.nvim',
    }
  })
  require('todo-comments').setup({})
end)

-- For lua development
later(function()
  add({
    source = 'folke/lazydev.nvim',
  })
  require('lazydev').setup({})
end)

-- Formatting/linting

--later(function()
--  add('stevearc/conform.nvim')
--  setupPlugin('formatting.lua')
--end)

-- later(function()
--   add('mfussenegger/nvim-lint')
--   setupPlugin('linting.lua')
-- end)

later(function()
  add('nvimtools/none-ls.nvim')
  setupPlugin('linting.lua')
end)


-- UI
later(function()
  add('nvim-lualine/lualine.nvim')
  setupPlugin('ui.lua')
end)

-- Special file types
later(function()
  add('MeanderingProgrammer/render-markdown.nvim')
  require('render-markdown').setup({})
end)

later(function()
  local function build()
    vim.notify('Building asciidoc', vim.log.levels.INFO)
    local obj = vim.system(
      { 'cd server && npm i' },
      { cwd = params.path }
    ):wait()

    if obj.code == 0 then
      vim.notify('Building asciidoc done', vim.log.levels.INFO)
    else
      vim.notify('Building asciidoc failed', vim.log.levels.ERROR)
    end
  end
  add({
    source ='tigion/nvim-asciidoc-preview',
    hooks = {
      post_install = build,
      post_checkout = build,
    }
  })
  require('asciidoc-preview').setup({})
end)

-- 3rd party integrations
later(function()
  add('ramilito/kubectl.nvim')
  require('kubectl').setup({})
end)

later(function()
  --add('Exafunction/codeium.nvim')

  add('monkoose/neocodeium')
  local neocodeium = require('neocodeium')
  neocodeium.setup()
  vim.keymap.set('i', '<m-l>', neocodeium.accept)
end)
