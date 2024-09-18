---@type git.command.options
local M = {
  cmd = { "status" },
}

function M:show_output(options)
  options.extmarks = {}
  options.keymaps = {
    {
      mode = "n",
      lhs = "<CR>",
      rhs = function()
        local file = vim.fn.expand "<cWORD>"
        if vim.uv.fs_stat(file) then
          vim.cmd.wincmd "w"
          vim.cmd.edit(file)
        end
      end,
    },
  }

  local branch = options.lines[1]:match "^On branch (.*)$"
  if branch then
    table.insert(
      options.extmarks,
      { line = 1, col = #options.lines[1] - #branch, end_col = #options.lines[1], hl = "GitBranch" }
    )
  end

  local upstream_start, upstream_end, upstream = options.lines[2]:find "'([a-zA-z0-9%-_]+/[a-zA-z0-9%-_]+)'"
  if upstream then
    table.insert(options.extmarks, { line = 2, col = upstream_start, end_col = upstream_end, hl = "GitUpstream" })
  end

  local highlight
  for i = 1, #options.lines do
    local line = options.lines[i]

    if line:find "Changes not staged for commit" then
      highlight = "GitUnstaged"
    elseif line:find "Untracked files" then
      highlight = "GitUntracked"
    elseif line:find "Changes to be committed" then
      highlight = "GitCommited"
    end

    if vim.startswith(line, "\t") then
      table.insert(options.extmarks, { line = i, col = 1, end_col = #line, hl = highlight })
    else
      local command_start, command_end = line:find '"[^"]+"'
      if command_start then
        table.insert(
          options.extmarks,
          { line = i, col = command_start + 1, end_col = command_end - 1, hl = "GitCommand" }
        )
      end
    end
  end
end

return require("git.commands.base").new(M)
