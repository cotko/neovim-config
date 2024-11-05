--
-- better biome with disabled linting which is provided by LSP
--

local nls = require('null-ls')
local helpers = require('null-ls.helpers')

local METHOD_DIAGNOSTICS = nls.methods.DIAGNOSTICS_ON_SAVE
local METHOD_CODE_ACTIONS = nls.methods.CODE_ACTION

local mod = {
  info = {
    name = 'biome-check',
    meta = {
      url = 'https://biomejs.dev',
      description = 'Formatter, linter, bundler, and more for JavaScript, TypeScript, JSON, HTML, Markdown, CSS and GraphQL.',
      notes = {
        'Currently support only JavaScript, TypeScript, JSON, CSS and GraphQL. See status [here](https://biomejs.dev/internals/language-support/)',
      },
    },
    filetypes = {
      'javascript',
      'typescript',
      'javascriptreact',
      'typescriptreact',
      'json',
      'jsonc',
      'css',
      'graphql',
    },
    generator_opts = {
      command = function()
        local local_binary = vim.fn.fnamemodify(
          './node_modules/.bin/biome',
          ':p'
        )
        return vim.loop.fs_stat(local_binary) and local_binary or
          'biome'
      end,

      args = { 'check', '--linter-enabled=false', '--colors=off', '$FILENAME' },
      from_stderr = true,
      to_stdin = false,
      format = 'raw',
      use_cache = true,
    },
  },
}

mod.get_diagnostics_from_output = function(params, done)
  local output = params.output

  if not params.output or output == '' then
    done()
  end

  local diagnostics = {}
  local current_header = nil
  local current_error = nil
  local current_diagnostic = nil
  local line_start = nil

  for line in output:gmatch('[^\r\n]+') do

    -- ignore empty lines
    if line:match('^%s*$') then goto continue end

    -- Check for error header
    -- (we only expect organize imports and format, lint is disabled)

    local header = line:match('^.-%s+(%w+)%s+━+')
    if header then
      current_header = header
      line_start = nil
    elseif current_header then

      local error_message = line:match('^%s*×%s*(.*)')
      if error_message then
        current_error = error_message
        line_start = nil
      elseif line:find('│') then
        local nums, content = line:match('^(.-)│(.*)')
        local trimmed_content = content:gsub('%·', ''):gsub('%s', '')

        if not nums or not content then goto continue end

        local line_nums = {}
        for num in nums:gmatch('%d+') do
          table.insert(line_nums, tonumber(num))
        end

        -- end of current diagnostics:
        -- a) if biome prints '·····' instead of line numbers
        -- b) if there is no - or + sign at the content part of diff

        local diag_end = false
        if not content:find('^%s*+') and not content:find('^%s*-') then
          diag_end = true
          line_start = line_nums[1]
        end

        if not diag_end and nums:gsub('%s', '') == '·····' then
          diag_end = true
          line_start = nil
        end

        if diag_end then
          current_diagnostic = nil
          goto continue
        end

        local is_content_empty = trimmed_content == ''
          or trimmed_content == '-'
          or not content:find('^%s*+') -- if no 'addiotions' we can consider empty change

        -- if #line_nums < 1 then goto continue end

        local diff_mode = #line_nums < 2 or line_nums[1] ~= line_nums[2]

        -- something to diff
        if diff_mode then
          if current_diagnostic == nil then
            current_diagnostic = {
              message = current_error .. '\n' .. content,
              severity = vim.diagnostic.severity.WARN,
              source = mod.info.name,

              row = line_nums[1],
              end_row = line_nums[1],
              col = 0,
              end_col = 0,

              user_data = {
                header = current_header,
                is_content_empty = is_content_empty,
                -- this is relevant for code actions
                line_start = line_start
              }
            }

            table.insert(diagnostics, current_diagnostic)
          else
            -- increase end row and add content to message
            current_diagnostic.end_row = current_diagnostic.end_row + 1
            current_diagnostic.message = current_diagnostic.message .. '\n' .. content
            current_diagnostic.user_data.is_content_empty =
              current_diagnostic.user_data.is_content_empty and is_content_empty
          end

        else
          -- no diff here any more
          current_diagnostic = nil
          line_start = nil
        end
      end
    end

    ::continue::
  end

  --print(vim.inspect(diagnostics))
  --print(params.output)
  done(diagnostics)
end

mod.get_code_actions_from_output = function(params, done)

  mod.get_diagnostics_from_output(params,
    function (diagnostics)
      if not diagnostics then done() end
      print(vim.inspect(diagnostics))

      local actions = {}
      for _, diagnostic in ipairs(diagnostics) do
        local is_relevant = not diagnostic.user_data.is_content_empty
          and params.row >= diagnostic.row and params.row <= diagnostic.end_row

        local is_format = diagnostic.user_data.header == 'format'

        if is_relevant and is_format then
          if diagnostic.user_data.header == 'format' then
            table.insert(actions, {
              title = 'Suppress formatting ('.. mod.info.name ..')',
              action = function()
                local row = params.row - 1
                if diagnostic.user_data.line_start then
                  row = diagnostic.user_data.line_start - 1
                end
                vim.api.nvim_buf_set_lines(
                  params.bufnr,
                  row - 1,
                  row - 1,
                  false,
                  { '// biome-ignore format: <explanation>' }
                )

              end
            })
          end
        end
      end

      done(actions)
    end)
end


mod.diagnostics = helpers.make_builtin(vim.tbl_deep_extend('force',
  {},
  mod.info,
  {
    method = METHOD_DIAGNOSTICS,
    factory = helpers.generator_factory,
    on_output = mod.get_diagnostics_from_output,
  }
))

mod.code_actions = helpers.make_builtin(vim.tbl_deep_extend('force',
  {},
  mod.info,
  {
    method = METHOD_CODE_ACTIONS,
    factory = helpers.generator_factory,
    on_output = mod.get_code_actions_from_output,
  }
))

mod.on_register = function()
  local id = nls.get_source(mod.info.name)[1].id
  local diagnostics = require('null-ls.diagnostics')
  local biome_ns = diagnostics.get_namespace(id)
  vim.diagnostic.config({
    virtual_text = {
      format = function(diag)
        if diag.user_data.is_content_empty then
          local msg = ': remove empty line'
          ---@diagnostic disable-next-line: undefined-field
          if diag.end_row - diag.row > 0 then msg = msg .. 's' end
          return diag.user_data.header .. msg
        else
          return diag.user_data.header
        end
      end
    }
  }, biome_ns)
end

mod.register = function()
  require('null-ls').register(mod.diagnostics)
  require('null-ls').register(mod.code_actions)
  mod.on_register()
end

return mod
