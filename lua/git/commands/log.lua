---@type git.command.options
local M = {
  cmd = { "log", "--pretty=%h -%C()%d%Creset %s (%cr)" },
}

function M:show_output(options)
  options.extmarks = {}
  options.keymaps = {
    {
      mode = "n",
      lhs = "<CR>",
      rhs = function(bufnr, win)
        local row = vim.api.nvim_win_get_cursor(win)[1]
        local line = vim.api.nvim_buf_get_lines(bufnr, row - 1, row, false)[1]
        local hash = line:match "^([^%s]+)"

        local utils = require "git.utils"

        local difflines = utils.git_command { "diff", string.format("%s^..%s", hash, hash) }

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
    local hash, branch, date

    hash, branch, date = line:match "^([^%s]+) %- (%([^%)]+%)).*(%([^%)]+%))$"

    if not hash then
      hash, date = line:match "^([^%s]+) %-.*(%([^%)]+%))$"
    end

    if not hash then
      break
    end

    table.insert(options.extmarks, { line = i, col = 1, end_col = #hash, hl = "GitCommit" })
    if branch then
      table.insert(options.extmarks, { line = i, col = #hash + 3, end_col = #hash + 3 + #branch, hl = "GitBranch" })
    end
    table.insert(options.extmarks, { line = i, col = #line - #date, end_col = #line, hl = "GitDate" })
  end
end

return M
