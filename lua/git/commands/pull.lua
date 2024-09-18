---@type git.command.options
local M = {
  cmd = { "pull" },
  show_output = true,
}

return require("git.commands.base").new(M)
