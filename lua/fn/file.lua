local fn = {}

local function file_exists(path)
  local _, error = vim.loop.fs_stat(path)
  return error == nil
end

local function clearPrompt()
  vim.api.nvim_command 'normal! :'
end

fn.better_copy = function(node)
  node = FNS.util.nvim_tree_get_node(node)
  if not node then return end

  if node == nil then
    FNS.util.warn("Got 'nil' as file node")
    return
  end

  if node.name == '..' then
    return
  end

  if node.fs_stat.type ~= 'file' then
    return 'is_folder'
  end

  local input_opts = {
    prompt = 'New name ',
    default = node.absolute_path,
    completion = 'file'
  }

  vim.ui.input(input_opts, function(new_file_path)
    clearPrompt()

    if not new_file_path then
      return
    end

    if file_exists(new_file_path) then
      FNS.util.warn 'Cannot copy: file already exists'
      return
    end

    local success = vim.loop.fs_copyfile(node.absolute_path, new_file_path)
    if not success then
      return vim.api.nvim_err_writeln(
        'Could not copy ' .. node.absolute_path .. ' to ' .. new_file_path
      )
    end
    vim.cmd('NvimTreeRefresh')
    vim.api.nvim_out_write(
      'Copied ' .. node.absolute_path .. ' ➜ ' .. new_file_path .. '\n'
    )
  end)
end

return fn
