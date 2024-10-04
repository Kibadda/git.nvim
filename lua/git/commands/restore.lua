---@type git.command.options
local M = {
  cmd = { "restore" },
}

function M:pre_run(fargs)
  if #fargs == 0 or (#fargs == 1 and fargs[1] == "--staged") then
    table.insert(fargs, ".")
  end
end

function M.completions(fargs)
  if #fargs > 1 then
    if fargs[1] == "--staged" then
      return require("git.cache").staged_files
    else
      return require("git.cache").unstaged_files
    end
  else
    return vim.list_extend({ "--staged" }, require("git.cache").unstaged_files)
  end
end

return M
