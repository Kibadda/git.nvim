---@class git.config.editor
---@field spell? { commit?: boolean, rebase?: boolean }
---@field window_config? vim.api.keyset.win_config
---@field treesitter? boolean
---@field cancel? string

---@class git.config.highlights
---@field Branch? vim.api.keyset.highlight
---@field Upstream? vim.api.keyset.highlight
---@field Unstaged? vim.api.keyset.highlight
---@field Untracked? vim.api.keyset.highlight
---@field Commited? vim.api.keyset.highlight
---@field Command? vim.api.keyset.highlight
---@field Stash? vim.api.keyset.highlight
---@field Commit? vim.api.keyset.highlight
---@field Date? vim.api.keyset.highlight

---@class git.config
---@field editor? git.config.editor
---@field highlights? git.config.highlights
---@field extra? table<string, git.command.options>

---@class git.internalconfig
local GitDefaultConfig = {
  editor = {
    spell = {
      commit = true,
      rebase = false,
    },
    window_config = {
      split = "below",
      win = 0,
      height = 20,
    },
    treesitter = true,
    cancel = "<C-c>",
  },
  highlights = {
    Branch = { fg = "#7daea3" },
    Upstream = { fg = "#7daea3" },
    Untracked = { fg = "#ea6962" },
    Unstaged = { fg = "#ea6962" },
    Commited = { fg = "#a9b665" },
    Command = { fg = "#d8a657" },
    Stash = { fg = "#d8a657" },
    Commit = { fg = "#ea6962" },
    Date = { fg = "#a9b665" },
  },
  extra = {},
}

---@type git.config | (fun(): git.config) | nil
vim.g.git = vim.g.git

---@type git.config
local opts = type(vim.g.git) == "function" and vim.g.git() or vim.g.git or {}

---@type git.internalconfig
local GitConfig = vim.tbl_deep_extend("force", {}, GitDefaultConfig, opts)

-- FIX: highlights should overwrite defaults
for name, val in pairs(opts.highlights or {}) do
  GitConfig.highlights[name] = val
end

local check = require "git.config.check"
local ok, err = check.validate(GitConfig)
if not ok then
  vim.notify("git: " .. err, vim.log.levels.ERROR)
end

return GitConfig
