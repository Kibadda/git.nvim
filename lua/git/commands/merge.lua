---@type git.command.options
local M = {
  cmd = { "merge" },
}

function M:pre_run(fargs)
  return #fargs > 0
end

function M.completions(fargs)
  if #fargs > 1 then
    return {}
  end

  return require("git.cache").full_branches
end

return M
