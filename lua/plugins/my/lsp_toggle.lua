local Tree = require('nui.tree')
local Popup = require('nui.popup')
local Line = require('nui.line')
local Node = Tree.Node

local bufnr = nil
local hidden = true

---@type NuiTree
local tree = nil

---@type NuiPopup
local popup = nil

local function convert_to_tree_nodes(items)
  local nodes = {}
  for _, item in ipairs(items) do

    local children = item.children and convert_to_tree_nodes(item.children)
      or {}

    local node = Node({
      text = item.name,
      data = item,
    }, children)

    node:expand()
    table.insert(nodes, node)
  end

  return nodes
end

local function get_node_text(node)
  local line = Line()
  line:append(string.rep("  ", node._depth - 1))

  local checked = ''
  if node.data.is_active then
    checked = node.data.is_active(bufnr) and "󰗠" or ""
  end

  line:append(checked .. ' ')
  line:append(node.text)
  return line
end

local function toggle_source()
  local pos = vim.fn.getpos('.')
  local node = tree:get_node(pos[2])
  if not node then
    return
  end

  if node.data.toggle then
    node.data.toggle(bufnr)
    tree:render()
  end
end

local function show()
  popup:mount()
  tree:render()
  vim.api.nvim_set_current_win(popup.winid)
  hidden = false
end

local function hide()
  popup:unmount()
  hidden = true
end

local function init()
  popup = Popup({
    enter = false,
    focusable = true,
    position = {
      row = 1,
      col = '95%',
    },
    relative = 'editor',
    anchor = 'NW',
    size = {
      width = '40%',
      height = 10,
    },
    border = {
      style = 'rounded',
      text = {
        top = 'LSP List (' .. FNS.util.get_buffer_name(bufnr) .. ')',
        top_align = 'center',
      },
      padding = {
        top = 1,
        bottom = 1,
        left = 2,
        right = 2,
      },
    },
    buf_options = {
      readonly = true,
    },
    win_options = {
      cursorline = true,
      wrap = false,
      winblend = 10,
    },
  })


  tree = Tree({
    bufnr = popup.bufnr,
    winid = popup.winid,
    nodes = convert_to_tree_nodes(FNS.lsp.get_lsp_sources()),
    prepare_node = get_node_text,
  })


  popup:map('n', { 'q', '<Esc>' }, function()
    hide()
  end, {})

  popup:on("BufLeave", function()
    hide()
  end, { once = true })

  popup:map('n',
    {' ', '<Tab>', '<CR>'},
    toggle_source,
    {}
  )

  popup:map('n',
    {'<LeftMouse>'},
    function()
      -- simulate mouse click
      vim.api.nvim_feedkeys(
        vim.api.nvim_replace_termcodes(
          '<LeftMouse>', true, false, true
        ), 'n', true)

      vim.schedule(toggle_source)
    end,
    { noremap = true, silent = true }
  )

  show()
end

vim.api.nvim_create_user_command('LSPToggler', function()
  local f = popup == nil
  if hidden then
    bufnr = vim.api.nvim_get_current_buf()
    init()
    show()
  else
    hide()
  end
end, { nargs = '*' })
