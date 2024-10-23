local tUtils = require('telescope.utils')
local tThemes = require('telescope.themes')

local path_display_opt = {
  filename_first = {
    reverse_directories = false
  },
  truncate = 3,
  shorten = {
    len = 3,
    exclude = {1, -1},
  },
}

local function setup()
  require('telescope').setup({
    defaults = tThemes.get_dropdown({
      layout_config = {
        prompt_position = 'top',
        mirror = true,
        width = 0.8,
        height = 0.9,
      },
      layout_strategy = 'vertical',
      path_display = path_display_opt,
    }),
    pickers = {
      colorscheme = {
        enable_preview = true,
      },
      find_files = {
        cwd = FNS.util.get_project_root(),
      },
      git_files = {
        cwd = FNS.util.get_project_root(),
      },
      grep_string = {
        cwd = FNS.util.get_project_root(),
      },
      oldfiles = {
        cwd = FNS.util.get_project_root(),
      },
      live_grep = {
        cwd = FNS.util.get_project_root(),
        entry_maker = function(line)
          -- I want file name + path to be in comment style
          -- for live greps

          local filename, lnum, col, text = string.match(
            line, "([^:]+):(%d+):(%d+):(.*)")

          local label = tUtils.transform_path(
            path_display_opt,
            filename
          )

          local display_label = label .. '  ' .. text
          local label_len = string.len(label)

          local path_style = {{
            { 0, label_len },
            "TelescopeResultsComment"
          }}

          return {
            value = line,
            ordinal = filename,
            display = function()
              return display_label, path_style
            end,
            filename = filename,
            lnum = tonumber(lnum),
            col = tonumber(col),
            text = text,
          }
        end,
      },
    },
    extensions = {
      fzf = {
        -- false will only do exact matching
        fuzzy = true,
        -- override the generic sorter
        override_generic_sorter = true,
         -- override the file sorter
        override_file_sorter = true,
        -- or "ignore_case" or "respect_case"
        -- the default case_mode is "smart_case"
        case_mode = "smart_case",
      },
      ["ui-select"] = {
        require("telescope.themes").get_dropdown({

        })
      },
      egrepify = {
        -- disabled by default, can be toggled
        permutations = true,
        prefixes = {
          -- ADDED ! to invert matches
          -- example prompt: ! sorter
          -- matches all lines that do not comprise sorter
          -- rg --invert-match -- sorter
          ["!"] = {
            flag = "invert-match",
          },
          -- HOW TO OPT OUT OF PREFIX
          -- ^ is not a default prefix and safe example
          ["^"] = false
        }
      },
      workspaces = {
        -- keep insert mode after selection in the picker,
        -- default is false
        keep_insert = true,
        -- Highlight group used for the path in the picker,
        -- default is "String"
        path_hl = "String"
      }
    },
  })
end

setup()
require('telescope').load_extension('undo')
require('telescope').load_extension('ui-select')
require('telescope').load_extension('fzf')
require('telescope').load_extension('egrepify')
require('telescope').load_extension("workspaces")

vim.api.nvim_create_autocmd('User', {
  pattern = 'WorkspacesLoaded',
  callback = setup
})
