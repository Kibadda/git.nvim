local M = {}

---@class git.config.editor
---@field spell? { commit?: boolean, rebase?: boolean }
---@field window_config? vim.api.keyset.win_config
---@field treesitter? boolean
---@field cancel? string

---@class git.config
---@field editor git.config.editor

---@type git.config
M.defaults = {
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

---@return git.config
function M.get()
  ---@type git.config
  local config = vim.g.git or {}

  vim.validate("config", config, "table")

  vim.validate("editor", config.editor, "table", true)

  if config.editor then
    vim.validate {
      spell = { config.editor.spell, "table", true },
      window_config = { config.editor.window_config, "table", true },
      treesitter = { config.editor.treesitter, "boolean", true },
      cancel = { config.editor.cancel, "string", true },
    }

    if config.editor.spell then
      vim.validate {
        commit = { config.editor.spell.commit, "boolean", true },
        rebase = { config.editor.spell.rebase, "boolean", true },
      }
    end
  end

  return vim.tbl_deep_extend("force", {}, M.defaults, config)
end

return M
