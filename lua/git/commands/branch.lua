---@type git.command.options
local M = {
  cmd = { "branch" },
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

    table.insert(fargs, branch)
  end
end

function M.completions(fargs)
  if #fargs == 0 then
    return vim.list_extend({ "--delete" }, require("git.cache").local_branches)
  elseif fargs[1] == "--delete" then
    return vim.list_extend({ "--force" }, require("git.cache").local_branches)
  else
    return require("git.cache").local_branches
  end
end

return require("git.commands.base").new(M)
