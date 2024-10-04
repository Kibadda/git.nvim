---@type git.command.options
local M = {
  cmd = { "commit" },
}

function M:pre_run(fargs)
  if #fargs == 1 and fargs[1] == "--fixup" then
    local commit = require("git.utils").select_commit()

    if not commit then
      return false
    end

    table.insert(fargs, commit)
  end
end

function M.completions(fargs)
  if vim.tbl_contains(fargs, "--fixup") then
    return {}
  elseif #fargs > 1 then
    return { "--amend", "--no-edit" }
  else
    return { "--amend", "--no-edit", "--fixup" }
  end
end

return M
