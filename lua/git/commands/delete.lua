---@type git.command.options
local M = {
  cmd = { "branch", "--delete" },
}

function M.completions()
  return vim.list_extend({ "--force" }, require("git.cache").local_branches)
end

return require("git.commands.base").new(M)
