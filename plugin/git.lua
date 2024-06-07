if vim.g.loaded_git then
  return
end

vim.g.loaded_git = 1

vim.api.nvim_create_autocmd("CmdlineLeave", {
  group = vim.api.nvim_create_augroup("GitNvim", { clear = true }),
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

vim.keymap.set("n", "gG", function()
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

  vim.ui.open(url)
end, { desc = "Open git project in browser" })
