local Command = require "git.commands.base"

---@type table<string, git.command>
local M = {}

M.status = Command.new {
  cmd = { "status" },
  show_output = true,
}

M.add = Command.new {
  cmd = { "add" },
  pre_run = function(_, fargs)
    if #fargs == 0 then
      table.insert(fargs, ".")
    end
  end,
  completions = function()
    return require("git.cache").unstaged_files
  end,
}

M.commit = Command.new {
  cmd = { "commit" },
  pre_run = function(_, fargs)
    if #fargs == 1 and fargs[1] == "--fixup" then
      local commit = require("git.utils").select_commit()

      if not commit then
        return false
      end

      table.insert(fargs, commit)
    end
  end,
  completions = function(fargs)
    if vim.tbl_contains(fargs, "--fixup") then
      return {}
    elseif #fargs > 1 then
      return { "--amend", "--no-edit" }
    else
      return { "--amend", "--no-edit", "--fixup" }
    end
  end,
}

M.push = Command.new {
  cmd = { "push" },
  show_output = true,
  pre_run = function(_, fargs)
    if #fargs == 1 and fargs[1] == "--set-upstream" then
      local remote = require("git.utils").select_remote()

      if not remote then
        return false
      end

      table.insert(fargs, remote)
      table.insert(fargs, require("git.utils").git_command({ "branch", "--show-current" })[1])
    end
  end,
  completions = function(fargs)
    if #fargs > 1 then
      return {}
    end

    return { "--force-with-lease", "--set-upstream" }
  end,
}

M.pull = Command.new {
  cmd = { "pull" },
  show_output = true,
}

M.switch = Command.new {
  cmd = { "switch" },
  pre_run = function(_, fargs)
    if #fargs == 0 then
      local branch

      vim.ui.input({
        prompt = "Enter branch name: ",
      }, function(input)
        branch = input
      end)

      if not branch or branch == "" then
        return false
      end

      table.insert(fargs, "--create")
      table.insert(fargs, branch)
    end
  end,
  completions = function(fargs)
    if #fargs > 1 then
      return {}
    end

    return require("git.cache").short_branches
  end,
}

M.fetch = Command.new {
  cmd = { "fetch" },
  show_output = true,
  completions = { "--prune" },
}

return M
