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

return M
