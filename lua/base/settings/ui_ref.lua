-- TODO: implement this shit:
--
-- should be able to toggle certain things,
-- like have a list of toggable LSP
-- and stuff like identing etc
--
-- Should be global + per workspace in case worksapce is detected
--
-- Settings should be stored in a config file and loaded at startup
-- in case of workspace, latter settings should prevail against global ones
--
local NuiTree = require("nui.tree")
local NuiSplit = require("nui.split")
local NuiText = require("nui.text")
local NuiLine = require("nui.line")
local event = require("nui.utils.autocmd").event

-- Create a split window on the left side
local split = NuiSplit({
  relative = "editor",
  position = "right",
  size = 30,
  enter = true,
})

-- Define the data structure for the tree nodes
local tree_data = {
  NuiTree.Node({
    text = "Option 1",
    checkbox = true,
    checked = false,
  }),
  NuiTree.Node({
    text = "Option 2",
    checkbox = true,
    checked = true,
  }),
  NuiTree.Node({
    text = "Select Option",
    dropdown = { "Choice 1", "Choice 2", "Choice 3" },
  }),
}

-- Function to create a line for a tree node
local function create_node_text(node)
  local line = NuiLine()
  if node.checkbox ~= nil then
    local checkbox_char = node.checked and "󰗠" or ""
    line:append(checkbox_char .. " ", "Normal")
  else
    line:append("  ", "Normal")
  end
  line:append(node.text, "Normal")
  return line
end

-- Create the tree
local tree = NuiTree({
  bufnr = 0,
  winid = split.winid,
  nodes = tree_data,
  prepare_node = function(node)
    return create_node_text(node)
  end,
})

-- Render the tree in the split
split:mount()
tree:render()

-- Key mapping for interacting with the tree
vim.keymap.set("n", "<CR>", function()
  local pos = vim.fn.getpos('.')
  local node = tree:get_node(pos[2])
  if not node then
    return
  end
  if node.checkbox ~= nil then
    -- Toggle checkbox state
    node.checked = not node.checked
    tree:render()
  elseif node.dropdown ~= nil then
    -- Open a select menu
    local NuiMenu = require("nui.menu")
    local items = {}
    for _, choice in ipairs(node.dropdown) do
      table.insert(items, NuiMenu.item(choice))
    end

    local menu = NuiMenu({
      position = "50%",
      size = {
        width = 20,
        height = #items,
      },
      border = {
        style = "rounded",
        text = {
          top = "[ Select Option ]",
          top_align = "center",
        },
      },
    }, {
      lines = items,
      on_close = function()
        -- Handle menu close if needed
      end,
      on_submit = function(item)
        -- Handle the selected item
        print("Selected: " .. item.text)
      end,
    })

    menu:mount()
  end
end, { noremap = true, nowait = true })

-- Optional: Handle mouse clicks
vim.keymap.set("n", "<LeftMouse>", function()
  local node = tree:get_node()
  if not node then
    return
  end
  -- Same logic as pressing <CR>
  -- (Repeat the code from the <CR> mapping or abstract it into a function)
end, { noremap = true, nowait = true })

