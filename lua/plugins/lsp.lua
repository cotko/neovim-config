local legendary = require('legendary')
local lsp = require('lspconfig')
local has_typescript_tools  = pcall(require, 'typescript-tools')

local lua_bin = FNS.util.which('lua-language-server')

if CompletionModule ~= 'coq' and CompletionModule ~= 'blink' then
  vim.notify('Completion module should be coq/blink', 3)
end

vim.diagnostic.config({
  virtual_text = {
    prefix = '●', -- Could be '■', '▎', 'x'
  },
  -- or Show virtual text only for errors
  -- virtual_text = { severity = { min = 'ERROR', max = 'ERROR' } },
	underline = true,
	signs = true,
  -- Don't update diagnostics when typing
	update_in_insert = false,
	severity_sort = true,
  float = { border = 'double' },
})

local servers = {
  -- See `:help lspconfig-all` for a list of all the pre-configured LSPs
  biome = {
    capabilities = {
      textDocument = {
        diagnostic = {
          -- dynamicRegistration = true,
        }
      }
    }
  },
  --eslint = {},
  gopls = {},
  jdtls = {},
  --
  -- Some languages (like typescript) have entire language plugins that can be useful:
  --    https://github.com/pmizio/typescript-tools.nvim
  --
  -- But for many setups, the LSP (`ts_ls` (prev `tsserver`))
  -- will work just fine
  -- commented out, will be added below unless
  -- 'pmizio/typescript-tools.nvim' is installed
  -- ts_ls = {},
  jq = {},
  lua_ls = {
    cmd = { lua_bin },
    -- filetypes = { ...},
    -- capabilities = {},
    settings = {
      Lua = {
        completion = {
          callSnippet = 'Replace',
        },
        workspace = {
          -- Don't analyze code from submodules
          ignoreSubmodules = true,
        },
        runtime = {
          -- Tell the language server which version of Lua
				  -- you're using (most likely LuaJIT in the case
					-- of Neovim)
          version = 'LuaJIT',
          -- Setup your lua path
          path = vim.split(package.path, ';'),
        },
				diagnostics = {
          -- Get the language server to recognize common globals
          globals = {
						'vim',
						'describe',
						'it',
						'before_each',
						'after_each',
					},
          disable = {
						'need-check-nil',
					},
          -- Don't make workspace diagnostic,
					-- as it consumes too much CPU and RAM
          workspaceDelay = -1,
        }
      },
    },
  },
  pyright = {},
  svelte = {},
  stylua = {},
}

local on_attach = function(event)
  local ti = require('telescope.builtin')
  local map = function(keys, cb, desc, mode)
    legendary.keymap({
      keys,
      cb,
      description = 'LSP: ' .. desc,
      opts = { buffer = event.buf },
      mode = mode,
    })
  end


  -- Jump to the definition of the word under your cursor.
  --  This is where a variable was first declared,
  --  or where a function is defined, etc.
  --  To jump back, press <C-t>.
  map('gd', ti.lsp_definitions,
    '[G]oto [D]efinition')

  -- Find references for the word under your cursor.
  map('gr', ti.lsp_references,
    '[G]oto [R]eferences')

  -- Jump to the implementation of the word under your cursor.
  --  Useful when your language has ways of declaring types
  --  without an actual implementation.
  map('gI', ti.lsp_implementations,
    '[G]oto [I]mplementation')

  -- Jump to the type of the word under your cursor.
  --  Useful when you're not sure what type a variable
  --  is and you want to see the definition of its *type*,
  --  not where it was *defined*.
  map('<leader>D', ti.lsp_type_definitions,
    'Type [D]efinition')

  -- Fuzzy find all the symbols in your current document.
  --  Symbols are things like variables, functions, types, etc.
  map('<leader>ds', ti.lsp_document_symbols,
    '[D]ocument [S]ymbols')

  -- Fuzzy find all the symbols in your current workspace.
  --  Similar to document symbols, except searches over your entire project.
  map('<leader>ws', ti.lsp_dynamic_workspace_symbols,
    '[W]orkspace [S]ymbols')

  -- Rename the variable under your cursor.
  --  Most Language Servers support renaming across files, etc.
  map('<leader>rn', vim.lsp.buf.rename,
    '[R]e[n]ame')

  -- Opens a popup that displays documentation about the
  -- word under your cursor
  --  See `:help K` for why this keymap.
  map('K', vim.lsp.buf.hover, 'Hover Documentation')
  map('<C-k>', vim.lsp.buf.signature_help,
    'Signature Documentation')

  -- Execute a code action, usually your cursor needs to be on top of an error
  -- or a suggestion from your LSP for this to activate.
  map('<leader>ca', vim.lsp.buf.code_action,
    '[C]ode [A]ction', { 'n', 'x' })

  -- This is not Goto Definition, this is Goto Declaration.
  -- For example, in C this would take you to the header.
  map('gD', vim.lsp.buf.declaration,
    '[G]oto [D]eclaration')

  -- The following two autocommands are used to highlight
  -- references of the word under your cursor when your
  -- cursor rests there for a little while.
  --  See `:help CursorHold` for information about when this is executed
  --  When you move your cursor, the highlights will be
  --  cleared (the second autocommand).
  local client = vim.lsp.get_client_by_id(event.data.client_id)

  if
    client and
    client.supports_method(
      vim.lsp.protocol.Methods.textDocument_documentHighlight
    )
  then
    local highlight_augroup = vim.api.nvim_create_augroup(
      'cotko-lsp-highlight',
      { clear = false }
    )

    vim.api.nvim_create_autocmd(
      { 'CursorHold', 'CursorHoldI' },
      {
        buffer = event.buf,
        group = highlight_augroup,
        callback = vim.lsp.buf.document_highlight,
      }
    )

    vim.api.nvim_create_autocmd(
      { 'CursorMoved', 'CursorMovedI' },
      {
        buffer = event.buf,
        group = highlight_augroup,
        callback = vim.lsp.buf.clear_references,
      }
    )

    vim.api.nvim_create_autocmd(
      'LspDetach',
      {
        group = vim.api.nvim_create_augroup(
          'cotko-lsp-detach',
          { clear = true }
        ),
        callback = function(event2)
          vim.lsp.buf.clear_references()
          vim.api.nvim_clear_autocmds {
            group = 'cotko-lsp-highlight',
            buffer = event2.buf
          }
        end,
      }
    )
  end

  -- The following code creates a keymap to toggle inlay
  -- hints in your code, if the language server you are
  -- using supports them
  if
    client and
    client.supports_method(
      vim.lsp.protocol.Methods.textDocument_inlayHint
    )
  then
    map(
      '<leader>th',
      function()
        local enabled = vim.lsp.inlay_hint.is_enabled({
          bufnr = event.buf,
        })
        vim.lsp.inlay_hint.enable(not enabled)
        vim.notify(
          'Inlay hints enabled: ' .. vim.inspect(not enabled),
          2
        )
      end,
      '[T]oggle Inlay [H]ints'
    )
  end
end

vim.api.nvim_create_autocmd('LspAttach', {
  group = AuGroup,
  callback = on_attach
})

if has_typescript_tools then
  vim.notify('TS: using typescript tools plugin', 2)
  require('plugins.typescript')
else
  vim.notify('TS: using default ts_ls plugin', 2)
  servers.ts_ls = {}
end



-- LSP servers and clients are able to communicate to
-- each other what features they support.
--  By default, Neovim doesn't support everything that
--  is in the LSP specification.
--  When you add nvim-cmp, luasnip, etc. Neovim now
--  has *more* capabilities.
--  So, we create new capabilities with nvim cmp, and
--  then broadcast that to the servers.
local capabilities = vim.lsp.protocol.make_client_capabilities()

require('mason').setup({
  PATH = 'append',
  registries = {
    'github:nvim-java/mason-registry',
    'github:mason-org/mason-registry',
  },
})

require('mason-tool-installer').setup({
  ensure_installed = vim.tbl_keys(servers)
})

require('java').setup({

  jdk = {
    -- install jdk using mason.nvim
    auto_install = false,
  },
  spring_boot_tools = {
    enable = false,
  },

  -- load java test plugins
  java_test = {
    enable = true,
  },

  -- load java debugger plugins
  java_debug_adapter = {
    enable = true,
  },

  notifications = {
    -- enable 'Configuring DAP' & 'DAP configured'
    -- messages on start up
    dap = true,
  },
  root_markers = {
    'settings.gradle',
    'settings.gradle.kts',
    'pom.xml',
    'build.gradle',
    'mvnw',
    'gradlew',
    'build.gradle',
    'build.gradle.kts',
  }
})

require('mason-lspconfig').setup({
  handlers = {
    function(server_name)
      local server = servers[server_name] or {}
      -- This handles overriding only values explicitly passed
      -- by the server configuration above. 
      -- Useful when disabling certain features of an LSP
      -- (for example, turning off formatting for ts_ls)
      server.capabilities = vim.tbl_deep_extend(
        'force',
        {},
        capabilities,
        server.capabilities or {}
      )

      if CompletionModule == 'coq' then
        lsp[server_name].setup(
          require('coq').lsp_ensure_capabilities(server)
        )
      else
        lsp[server_name].setup(server)
      end

    end,
  },
})

require('plugins.blink')
