---@type git.command.options
local M = {
  cmd = { "config" },
  show_output = true,
}

return require("git.commands.base").new(M)
