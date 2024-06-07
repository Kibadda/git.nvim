local M = {}

---@param data table
function M.run(data)
  local cmd = table.remove(data.fargs, 1)

  local command = require("git.commands")[cmd]

  if not command then
    vim.notify("command '" .. cmd .. "' not found", vim.log.levels.WARN)
    return
  end

  command:run(data.fargs)
end

---@param cmdline string
---@return string[]?
function M.complete(cmdline)
  local cmd, cmd_arg_lead = cmdline:match "^Git%s+(%S+)%s+(.*)$"

  local commands = require "git.commands"

  if cmd and commands[cmd] and cmd_arg_lead then
    return commands[cmd]:complete(cmd_arg_lead)
  end

  cmd = cmdline:match "^Git%s+(.*)$"

  if cmd then
    local complete = vim.tbl_filter(function(command)
      return string.find(command, "^" .. cmd) ~= nil
    end, vim.tbl_keys(commands))

    table.sort(complete)

    return complete
  end
end

return M
