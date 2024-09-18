---@type git.command.options
local M = {
  cmd = { "reset" },
}

function M.completions()
  return vim.list_extend({ "--hard" }, require("git.cache").staged_files)
end

return require("git.commands.base").new(M)
