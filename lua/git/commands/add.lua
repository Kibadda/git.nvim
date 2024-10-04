---@type git.command.options
local M = {
  cmd = { "add" },
}

function M:pre_run(fargs)
  if #fargs == 0 or (#fargs == 1 and fargs[1] == "--edit") then
    table.insert(fargs, ".")
  end
end

function M.completions()
  return vim.list_extend({ "--edit" }, require("git.cache").unstaged_files)
end

return M
