local M = {}

function M.status()
  if vim.uv.fs_stat ".git/MERGE_HEAD" then
    return "merge"
  end

  if vim.fn.isdirectory ".git/rebase-apply" == 1 or vim.fn.isdirectory ".git/rebase-merge" == 1 then
    return "rebase"
  end

  return ""
end

function M.branch()
  return require("git.utils").git_command({ "branch", "--show-current" })[1]
end

function M.diff()
  local diff = {
    added = 0,
    changed = 0,
    removed = 0,
  }

  if vim.bo[0].buftype ~= "" then
    return diff
  end

  local bufname = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":.")
  local current = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local index = require("git.utils").git_command { "show", (":%s"):format(bufname) }

  ---@diagnostic disable-next-line:missing-fields
  vim.diff(table.concat(index, "\n"), table.concat(current, "\n"), {
    ignore_whitespace_change = true,
    on_hunk = function(_, c1, _, c2)
      if c1 == 1 and c2 > 1 then
        diff.added = diff.added + c2
      elseif c1 > 1 and c2 == 1 then
        diff.removed = diff.removed + c1
      else
        local delta = math.min(c1, c2)
        diff.changed = diff.changed + delta
        diff.added = diff.added + c2 - delta
        diff.remove = diff.removed + c1 - delta
      end

      return 0
    end,
  })

  return diff
end

return M
