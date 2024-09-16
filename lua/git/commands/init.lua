local Command = require "git.commands.base"

---@type table<string, git.command>
local M = {}

M.status = Command.new {
  cmd = { "status" },
  show_output = function(_, options)
    options.extmarks = {}

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
  pre_run = function(self, fargs)
    if fargs[1] == "list" then
      self.show_output = function(_, options)
        options.extmarks = {}
        options.keymaps = {
          {
            mode = "n",
            lhs = "<CR>",
            rhs = function(bufnr, win)
              local row = vim.api.nvim_win_get_cursor(win)[1]
              local line = vim.api.nvim_buf_get_lines(bufnr, row - 1, row, false)[1]
              local stash = line:match "^(stash@{%d+})"

              local utils = require "git.utils"

              local difflines = utils.git_command { "stash", "show", "-p", stash }

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
          local stash = line:match "^(stash@{%d+})"

          if stash then
            table.insert(options.extmarks, { line = i, col = 1, end_col = #stash, hl = "GitStash" })
          end
        end

        self.show_output = nil
      end
    elseif fargs[1] == "drop" or fargs[1] == "pop" or fargs[1] == "apply" then
      local stash = require("git.utils").select_stash()

      if not stash then
        return false
      end

      table.insert(fargs, stash)
    else
      local insert
      for i, arg in ipairs(fargs) do
        if arg == "--message" then
          insert = i + 1
          break
        end
      end

      if insert then
        local message

        vim.ui.input({
          prompt = "Enter branch name: ",
        }, function(input)
          message = input
        end)

        if not message or message == "" then
          return false
        end

        table.insert(fargs, insert, message)
      end
    end
  end,
  completions = function(fargs)
    if #fargs > 1 then
      if vim.tbl_contains({ "drop", "pop", "apply", "list" }, fargs[1]) then
        return {}
      else
        return { "--staged", "--include-untracked", "--message" }
      end
    else
      return { "drop", "pop", "apply", "list", "--staged", "--include-untracked", "--message" }
    end
  end,
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

      table.insert(options.extmarks, { line = i, col = 1, end_col = #hash, hl = "GitCommit" })
      if branch then
        table.insert(options.extmarks, { line = i, col = #hash + 3, end_col = #hash + 3 + #branch, hl = "GitBranch" })
      end
      table.insert(options.extmarks, { line = i, col = #line - #date, end_col = #line, hl = "GitDate" })
    end
  end,
}

M.diff = Command.new {
  cmd = { "diff" },
  completions = function()
    return require("git.cache").unstaged_files
  end,
  show_output = function(_, options)
    options.options.filetype = "diff"
  end,
}

return M
