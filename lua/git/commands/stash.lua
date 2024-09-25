---@type git.command.options
local M = {
  cmd = { "stash" },
}

function M:pre_run(fargs)
  if fargs[1] == "list" then
    self.show_output = function(_, options)
      options.extmarks = {}
      options.keymaps = {
        {
          mode = "n",
          lhs = "<CR>",
          rhs = function(bufnr, win)
            local row = vim.api.nvim_win_get_cursor(win)[1]
            local line = vim.api.nvim_buf_get_lines(bufnr, row - 1, row, false)[1]
            local stash = line:match "^(stash@{%d+})"

            local utils = require "git.utils"

            local difflines = utils.git_command { "stash", "show", "-p", stash }

            utils.open_buffer {
              name = "diff",
              lines = difflines,
              options = {
                modifiable = false,
                modified = false,
                filetype = "diff",
              },
            }
          end,
        },
      }

      for i, line in ipairs(options.lines) do
        local stash = line:match "^(stash@{%d+})"

        if stash then
          table.insert(options.extmarks, { line = i, col = 1, end_col = #stash, hl = "GitStash" })
        end
      end

      self.show_output = nil
    end
  elseif fargs[1] == "drop" or fargs[1] == "pop" or fargs[1] == "apply" then
    local stash = require("git.utils").select_stash()

    if not stash then
      return false
    end

    table.insert(fargs, stash)
  else
    local insert
    for i, arg in ipairs(fargs) do
      if arg == "--message" then
        insert = i + 1
        break
      end
    end

    if insert then
      local message

      vim.ui.input({
        prompt = "Enter message: ",
      }, function(input)
        message = input
      end)

      if not message or message == "" then
        return false
      end

      table.insert(fargs, insert, message)
    end
  end
end

function M.completions(fargs)
  if #fargs > 1 then
    if vim.tbl_contains({ "drop", "pop", "apply", "list" }, fargs[1]) then
      return {}
    else
      return { "--staged", "--include-untracked", "--message" }
    end
  else
    return { "drop", "pop", "apply", "list", "--staged", "--include-untracked", "--message" }
  end
end

return require("git.commands.base").new(M)
