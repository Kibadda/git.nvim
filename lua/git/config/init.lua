---@class git.config.editor
---@field spell? { commit?: boolean, rebase?: boolean }
---@field window_config? vim.api.keyset.win_config
---@field treesitter? boolean
---@field cancel? string

---@class git.config
---@field editor? git.config.editor

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
}

---@type git.config | (fun(): git.config) | nil
vim.g.git = vim.g.git

---@type git.config
local opts = type(vim.g.git) == "function" and vim.g.git() or vim.g.git or {}

---@type git.internalconfig
local GitConfig = vim.tbl_deep_extend("force", {}, GitDefaultConfig, opts)

local check = require "git.config.check"
local ok, err = check.validate(GitConfig)
if not ok then
  vim.notify("git: " .. err, vim.log.levels.ERROR)
end

return GitConfig
