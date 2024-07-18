local Command = require "git.commands.base"

---@type table<string, git.command>
local M = {}

M.status = Command.new {
  cmd = { "status" },
  show_output = function(_, options)
    options.extmarks = {}

    local branch = options.lines[1]:match "^On branch (.*)$"
    if branch then
      table.insert(options.extmarks, { line = 1, col = 11, end_col = #options.lines[1], hl = "Blue" })
    end

    local upstream = options.lines[2]:match "'([a-zA-z%-]+/[a-zA-z%-]+)'"
    if upstream then
      table.insert(
        options.extmarks,
        { line = 2, col = #options.lines[2] - #upstream - 1, end_col = #options.lines[2] - 2, hl = "Blue" }
      )
    end

    local highlight
    for i = 3, #options.lines do
      local line = options.lines[i]

      if line:find "Changes not staged for commit" or line:find "Untracked files" then
        highlight = "Red"
      elseif line:find "Changes to be committed" then
        highlight = "Green"
      end

      if vim.startswith(line, "\t") then
        table.insert(options.extmarks, { line = i, col = 1, end_col = #line, hl = highlight })
      else
        local command_start, command_end = line:find '"[^"]+"'
        if command_start then
          table.insert(
            options.extmarks,
            { line = i, col = command_start + 1, end_col = command_end - 1, hl = "Yellow" }
          )
        end
      end
    end
  end,
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

M.rebase = Command.new {
  cmd = { "rebase" },
  pre_run = function(_, fargs)
    local should_select_commit = true

    for _, arg in ipairs(fargs) do
      if arg == "--abort" or arg == "--skip" or arg == "--continue" or not vim.startswith(arg, "--") then
        should_select_commit = false
        break
      end
    end

    if should_select_commit then
      local commit = require("git.utils").select_commit()

      if not commit then
        return false
      end

      table.insert(fargs, commit .. "^")
    end
  end,
  completions = function(fargs)
    if vim.fn.isdirectory ".git/rebase-apply" == 1 or vim.fn.isdirectory ".git/rebase-merge" == 1 then
      if #fargs > 1 then
        return {}
      else
        return { "--abort", "--skip", "--continue" }
      end
    else
      return vim.list_extend({ "--interactive", "--autosquash" }, require("git.cache").short_branches)
    end
  end,
}

M.merge = Command.new {
  cmd = { "merge" },
  pre_run = function(_, fargs)
    return #fargs > 0
  end,
  completions = function(fargs)
    if #fargs > 1 then
      return {}
    end

    return require("git.cache").full_branches
  end,
}

M.stash = Command.new {
  cmd = { "stash" },
  completions = { "--staged", "--include-untracked" },
}

M.reset = Command.new {
  cmd = { "reset" },
  completions = function()
    return vim.list_extend({ "--hard" }, require("git.cache").staged_files)
  end,
}

M.delete = Command.new {
  cmd = { "branch", "--delete" },
  completions = function()
    return vim.list_extend({ "--force" }, require("git.cache").local_branches)
  end,
}

M.log = Command.new {
  cmd = { "log", "--pretty=%h -%C()%d%Creset %s (%cr)" },
  show_output = function(_, options)
    options.name = "log"
    options.extmarks = {}
    options.keymaps = {
      {
        mode = "n",
        lhs = "<CR>",
        rhs = function(bufnr, win)
          local row = vim.api.nvim_win_get_cursor(win)[1]
          local line = vim.api.nvim_buf_get_lines(bufnr, row - 1, row, false)[1]
          local hash = line:match "^([^%s]+)"

          local utils = require "git.utils"

          local difflines = utils.git_command { "diff", string.format("%s^..%s", hash, hash) }

          utils.open_buffer {
            name = "diff",
            lines = difflines,
            options = {
              modifiable = false,
              modified = false,
              filetype = "diff",
            },
          }
        end,
      },
    }

    for i, line in ipairs(options.lines) do
      local hash, branch, date

      hash, branch, date = line:match "^([^%s]+) %- (%([^%)]+%)).*(%([^%)]+%))$"

      if not hash then
        hash, date = line:match "^([^%s]+) %-.*(%([^%)]+%))$"
      end

      if not hash then
        break
      end

      table.insert(options.extmarks, { line = i, col = 1, end_col = #hash, hl = "Red" })
      if branch then
        table.insert(options.extmarks, { line = i, col = #hash + 3, end_col = #hash + 3 + #branch, hl = "Yellow" })
      end
      table.insert(options.extmarks, { line = i, col = #line - #date, end_col = #line, hl = "Green" })
    end
  end,
}

return M
