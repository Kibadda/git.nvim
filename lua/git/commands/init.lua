local commands = vim.tbl_extend("keep", {
  add = require "git.commands.add",
  branch = require "git.commands.branch",
  commit = require "git.commands.commit",
  config = require "git.commands.config",
  diff = require "git.commands.diff",
  fetch = require "git.commands.fetch",
  log = require "git.commands.log",
  merge = require "git.commands.merge",
  pull = require "git.commands.pull",
  push = require "git.commands.push",
  rebase = require "git.commands.rebase",
  reset = require "git.commands.reset",
  restore = require "git.commands.restore",
  stash = require "git.commands.stash",
  status = require "git.commands.status",
  switch = require "git.commands.switch",
}, require("git.config").extra)

local base = require "git.commands.base"

for key, command in pairs(commands) do
  commands[key] = base.new(command)
end

return commands --[[@as table<string, git.command>]]
