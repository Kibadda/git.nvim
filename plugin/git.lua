if vim.g.loaded_git then
  return
end

vim.g.loaded_git = 1

local group = vim.api.nvim_create_augroup("GitNvim", { clear = true })

vim.api.nvim_create_autocmd("CmdlineLeave", {
  group = group,
  callback = function()
    local cache = require "git.cache"
    for key in pairs(cache) do
      cache[key] = nil
    end
  end,
})

vim.api.nvim_create_user_command("Git", function(data)
  require("git").run(data)
end, {
  bang = false,
  bar = false,
  desc = "Git wrapper",
  nargs = "+",
  complete = function(_, cmdline, _)
    return require("git").complete(cmdline)
  end,
})

local function get_url()
  local utils = require "git.utils"

  local remote = utils.git_command({ "remote" })[1]

  if not remote or remote == "" then
    vim.notify("no remote found", vim.log.levels.WARN)
    return
  end

  local url = utils.git_command({
    "config",
    "--get",
    string.format("remote.%s.url", remote),
  })[1]

  if not url or url == "" then
    vim.notify("no url found for remote " .. remote, vim.log.levels.WARN)
    return
  end

  if vim.startswith(url, "git@") then
    url = url:gsub("%.git", ""):gsub(":", "/"):gsub("git@", "https://")
  end

  return url
end

vim.keymap.set("n", "gG", function()
  local url = get_url()

  if url then
    vim.ui.open(url)
  end
end, { desc = "Open git project in browser" })

vim.keymap.set("n", "gF", function()
  local url = get_url()

  if not url then
    return
  end

  local utils = require "git.utils"

  local branch = utils.git_command({ "rev-parse", "--abbrev-ref", "HEAD" })[1]

  if not branch or branch == "" then
    vim.notify("no branch found", vim.log.levels.WARN)
    return
  end

  local bufname = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":.")

  vim.ui.open(url .. "/blob/" .. branch .. "/" .. bufname)
end, { desc = "Open git file in browser" })

vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI", "BufEnter", "FocusGained" }, {
  group = group,
  callback = function(args)
    local cache = require("git.status").cache

    cache[args.buf] = cache[args.buf] or {}

    local utils = require "git.utils"

    utils.git_command({ "rev-parse", "--abbrev-ref", "HEAD" }, function(branch)
      if not branch[1] or branch[1] == "" then
        cache[args.buf].branch = "no git"
      elseif branch[1] ~= "HEAD" then
        cache[args.buf].branch = branch[1]
      else
        utils.git_command({ "rev-parse", "--short", "HEAD" }, function(hash)
          if not hash[1] or hash[1] == "" then
            cache[args.buf].branch = "HEAD"
          else
            cache[args.buf].branch = "HEAD " .. hash[1]
          end
        end)
      end
    end)

    if vim.bo[args.buf].buftype == "" then
      local bufname = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":.")

      utils.git_command(
        { "show", (":%s"):format(bufname) },
        vim.schedule_wrap(function(result)
          if not vim.api.nvim_buf_is_valid(args.buf) then
            return
          end

          local current = vim.api.nvim_buf_get_lines(args.buf, 0, -1, false)

          local diff = { added = 0, changed = 0, removed = 0 }

          ---@diagnostic disable-next-line:missing-fields
          vim.diff(table.concat(result, "\n"), table.concat(current, "\n"), {
            ignore_whitespace_change = true,
            on_hunk = function(_, c1, _, c2)
              if c1 == 1 and c2 > 1 then
                diff.added = diff.added + c2
              elseif c1 > 1 and c2 == 1 then
                diff.removed = diff.removed + c1
              else
                local delta = math.min(c1, c2)
                diff.changed = diff.changed + delta
                diff.added = diff.added + c2 - delta
                diff.removed = diff.removed + c1 - delta
              end

              return 0
            end,
          })

          cache[args.buf].diff = diff
        end)
      )
    end
  end,
})
