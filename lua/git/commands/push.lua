---@type git.command.options
local M = {
  cmd = { "push" },
}

function M:pre_run(fargs)
  if #fargs == 1 and fargs[1] == "--set-upstream" then
    local remote = require("git.utils").select_remote()

    if not remote then
      return false
    end

    table.insert(fargs, remote)
    table.insert(fargs, require("git.utils").git_command({ "branch", "--show-current" })[1])
  end
end

function M.completions(fargs)
  if #fargs > 1 then
    return {}
  end

  return { "--force-with-lease", "--set-upstream" }
end

return require("git.commands.base").new(M)
