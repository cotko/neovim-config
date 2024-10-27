--
-- better biome with disabled linting
-- which is provided by LSP
--

local enabled = true

local function add_biome_diagnostics(diagnostics, current_error)
  for _, line_number in ipairs(current_error.lines) do
    local line_diff = table.concat(current_error.line_diff[line_number],'\n')
    local is_empty = line_diff:gsub('%·', ''):gsub('%s', '') == '-'
    local message = ''
    local header = current_error.header

    if is_empty then
      message = '<remove this line>'
      header = header .. ': remove this line'
    else
      message = (
        current_error.message
        .. '\n' ..
        table.concat(current_error.line_diff[line_number],'\n')
      ) -- :gsub('%→', ' '):gsub('%·', ' ')
    end

    table.insert(diagnostics, {
      lnum = line_number,
      col = 0,
      end_lnum = line_number,
      end_col = 0,
      severity = vim.diagnostic.severity.WARN,
      source = 'biome',
      message = message,
      user_data = { header = header }
    })
  end
end

local function parse_biome(output)
  local diagnostics = {}
  local lines = {}
  for line in output:gmatch("[^\r\n]+") do
    table.insert(lines, line)
  end

  local current_error = nil
  local processed = false

  for _, line in ipairs(lines) do
    -- Check for error header
    local header = line:match("^.-%s+(%w+)%s+━+")
    if header then
      current_error = {
        header = header,
        message = '',
        lines = {},
        line_diff = {},
      }
    elseif current_error then
      -- Check for error message
      local error_message = line:match("^%s*×%s*(.*)")
      if error_message then
        current_error.message = error_message
      elseif line:find("│") then
        -- Parse the diff line
        local left, content = line:match("^(.-)│(.*)")
        if left and content then
          processed = true
          local line_nums = {}
          for num in left:gmatch("%d+") do
            table.insert(line_nums, tonumber(num))
          end
          local line_number = -1
          if #line_nums > 0 then
            line_number = line_nums[1] - 1  -- Adjust for 0-based index
            if current_error.line_diff[line_number] == nil then
              current_error.line_diff[line_number] = {}
            end
          end
          if content:find("^%s*-") and #line_nums > 0 then
            table.insert(current_error.lines, line_number)

            table.insert(current_error.line_diff[line_number], content)
          end
          if content:find("^%s*+") and #line_nums > 0 then
            table.insert(current_error.line_diff[line_number], content)
          end
        end
      elseif line:match("^%s*$") then
        -- Ignore empty lines
        if current_error ~= nil and processed then
          add_biome_diagnostics(diagnostics, current_error)
          current_error = nil
          processed = false
        end
      end
    end
  end

  --print(vim.inspect(diagnostics))
  return diagnostics
end

return function()
  vim.api.nvim_create_autocmd('User', {
    pattern = 'BiomeToggle',
    group = AuGroup,
    callback = function()
      enabled = not enabled
      vim.notify('Biome linter enabled: ' .. vim.inspect(enabled), 3)
    end
  })

  return {
    cmd = function()
      local local_binary = vim.fn.fnamemodify(
        './node_modules/.bin/biome',
        ':p'
      )

      return vim.loop.fs_stat(local_binary) and local_binary or
        'biome'

    end,
    stdin = false,
    append_fname = true,
    args = {'check', '--linter-enabled=false', '--colors=off'},
    stream = 'stderr', -- ('stdout' | 'stderr' | 'both')
    ignore_exitcode = true,
    ---@diagnostic disable-next-line: unused-local
    parser = function (output, bufnr, linter_cwd)
      if not enabled then return {} end
      return parse_biome(output)
    end
  }

end

