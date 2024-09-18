---@type git.command.options
local M = {
  cmd = { "fetch" },
  show_output = true,
  completions = { "--prune" },
}

return require("git.commands.base").new(M)
