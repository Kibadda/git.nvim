---@type table<string, git.command>
return {
  add = require "git.commands.add",
  commit = require "git.commands.commit",
  config = require "git.commands.config",
  delete = require "git.commands.delete",
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
}
