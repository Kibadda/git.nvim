---@type git.command.options
local M = {
  cmd = { "switch" },
}

function M:pre_run(fargs)
  if #fargs == 0 then
    local branch

    vim.ui.input({ prompt = "Enter branch name: " }, function(input)
      branch = input
    end)

    if not branch or branch == "" then
      return false
    end

    table.insert(fargs, "--create")
    table.insert(fargs, branch)
  end
end

function M.completions(fargs)
  if #fargs > 1 then
    return {}
  end

  return require("git.cache").short_branches
end

return M
