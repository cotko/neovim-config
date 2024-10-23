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

  print("identing set:", (not tabs and (indent .. " spaces") or "tabs"))
end

fn.toggleLineNumbering = function()
  local nl = vim.o.relativenumber and vim.o.number
  vim.o.number = not nl
  vim.o.relativenumber = not nl
end

fn.toggleHlSearch = function()
  vim.o.hlsearch = not vim.o.hlsearch
  print("hl search: " .. vim.inspect(vim.o.hlsearch))
end

fn.get_project_root = function()
  return vim.fn.getcwd()
end

return fn
