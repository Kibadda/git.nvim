local M = {}

--- small wrapper around vim.validate
---@param path string
---@param tbl table
---@return boolean
---@return string?
local function validate(path, tbl)
  local prefix = "invalid config: "
  local ok, err = pcall(vim.validate, tbl)
  return ok or false, prefix .. (err and path .. "." .. err or path)
end

--- validate given config
---@param config git.internalconfig
---@return boolean
---@return string?
function M.validate(config)
  local ok, err

  ok, err = validate("git", {
    editor = { config.editor, "table", true },
  })
  if not ok then
    return false, err
  end

  ok, err = validate("git.editor", {
    spell = { config.editor.spell, "table", true },
    window_config = { config.editor.window_config, "table", true },
    treesitter = { config.editor.treesitter, "boolean", true },
    cancel = { config.editor.cancel, "string", true },
  })
  if not ok then
    return false, err
  end

  ok, err = validate("git.editor.spell", {
    commit = { config.editor.spell.commit, "boolean", true },
    rebase = { config.editor.spell.rebase, "boolean", true },
  })
  if not ok then
    return false, err
  end

  return true
end

return M
