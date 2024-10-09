local M = {}

M.cache = setmetatable({}, {
  __index = function()
    return {
      branch = "no git",
      diff = {
        added = 0,
        changed = 0,
        removed = 0,
      },
    }
  end,
})

function M.merge_status()
  if vim.uv.fs_stat ".git/MERGE_HEAD" then
    return "merge"
  end

  if vim.fn.isdirectory ".git/rebase-apply" == 1 or vim.fn.isdirectory ".git/rebase-merge" == 1 then
    return "rebase"
  end

  return ""
end

function M.branch()
  return M.cache[vim.api.nvim_get_current_buf()].branch
end

function M.diff()
  return M.cache[vim.api.nvim_get_current_buf()].diff
end

return M
