---@type git.command.options
local M = {
  cmd = { "rebase" },
}

function M:pre_run(fargs)
  local should_select_commit = true

  for _, arg in ipairs(fargs) do
    if arg == "--abort" or arg == "--skip" or arg == "--continue" or not vim.startswith(arg, "--") then
      should_select_commit = false
      break
    end
  end

  if should_select_commit then
    local commit = require("git.utils").select_commit()

    if not commit then
      return false
    end

    table.insert(fargs, commit .. "^")
  end
end

function M.completions(fargs)
  if vim.fn.isdirectory ".git/rebase-apply" == 1 or vim.fn.isdirectory ".git/rebase-merge" == 1 then
    if #fargs > 1 then
      return {}
    else
      return { "--abort", "--skip", "--continue" }
    end
  else
    return vim.list_extend({ "--interactive", "--autosquash" }, require("git.cache").short_branches)
  end
end

return M
