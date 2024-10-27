local fn = {}

fn.setIndent = function (ref, indent, tabs)
  local expandtab = not tabs

  -- ref.breakindent = true
  ref.sts = indent
  ref.sw = indent
  ref.ts = indent
  ref.expandtab = expandtab
  ref.smartindent = true
end

fn.toggleIndents = function ()
  local indent = vim.g.ts
  local tabs = false
  if indent == 2 and vim.g.expandtab then
    indent = 4
  elseif indent == 4 and vim.g.expandtab then
    indent = 4
    tabs = true
  else
    indent = 2
  end

  fn.setIndent(vim.g, indent, tabs)
  fn.setIndent(vim.opt, indent, tabs)

  vim.notify(
    (not tabs and (indent .. " spaces") or "tabs") .. ' identation',
    2
  )
end

fn.toggleLineNumbering = function()
  local nl = vim.o.relativenumber and vim.o.number
  vim.o.number = not nl
  vim.o.relativenumber = not nl
end

fn.toggleHlSearch = function()
  vim.o.hlsearch = not vim.o.hlsearch
  vim.notify('hl search: ' .. vim.inspect(vim.o.hlsearch))
end

fn.get_project_root = function()
  return vim.fn.getcwd()
end

fn.which = function(cmd)
  return vim.fn.systemlist('PATH=/usr/bin:$PATH which ' .. cmd)[1]
end

fn.register_setting = function(s)
  vim.api.nvim_exec_autocmds(
    'User',
    { pattern = 'RegisterSetting', data = s }
  )
end

vim.api.nvim_create_autocmd('User', {
  pattern = 'SetupComplete',
  callback = function()
    FNS.util.register_setting({
      type = 'select',
      label = 'Indentation',
      callback = function(indent, tabs)
        fn.setIndent(vim.g, indent, tabs)
        fn.setIndent(vim.o, indent, tabs)
      end,
      values = {
        {
          label = '2 spaces',
          args = {
            2,
            false,
          },
        },
        {
          label = '4 spaces',
          args = {
            4,
            false,
          },
        },
        {
          label = 'tabs',
          args = {
            4,
            true,
          },
        },
      }
    })
  end
})

return fn
