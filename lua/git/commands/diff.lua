---@type git.command.options
local M = {
  cmd = { "diff" },
}

function M.completions(fargs)
  if #fargs > 1 then
    if fargs[1] == "--cached" then
      return require("git.cache").staged_files
    else
      return require("git.cache").unstaged_files
    end
  else
    return vim.list_extend({ "--cached" }, require("git.cache").unstaged_files)
  end
end

function M:show_output(options)
  options.options.filetype = "diff"
end

return M
