local M = {
  is_valid = false,
}

--- validate given config
---@param config git.internalconfig
---@return boolean
---@return string[]
function M.validate(config)
  local errors = {}

  --- small wrapper around vim.validate
  ---@param name string
  ---@param value any
  ---@param types any|any[]
  ---@param optional? boolean
  local function validate(name, value, types, optional)
    local ok, err = pcall(vim.validate, name, value, types, optional)

    if not ok then
      table.insert(errors, err)
    end

    return ok
  end

  if validate("git.editor", config.editor, "table", true) and config.editor then
    if validate("git.editor.spell", config.editor.spell, "table", true) and config.editor.spell then
      validate("git.editor.spell.commit", config.editor.spell.commit, "boolean", true)
      validate("git.editor.spell.rebase", config.editor.spell.rebase, "boolean", true)
    end

    validate("git.editor.window_config", config.editor.window_config, "table", true)
    validate("git.editor.treesitter", config.editor.treesitter, "boolean", true)
    validate("git.editor.cancel", config.editor.cancel, "string", true)
  end

  if validate("git.highlights", config.highlights, "table", true) and config.highlights then
    validate("git.highlights.Branch", config.highlights.Branch, "table", true)
    validate("git.highlights.Upstream", config.highlights.Upstream, "table", true)
    validate("git.highlights.Untracked", config.highlights.Untracked, "table", true)
    validate("git.highlights.Unstaged", config.highlights.Unstaged, "table", true)
    validate("git.highlights.Commited", config.highlights.Commited, "table", true)
    validate("git.highlights.Command", config.highlights.Command, "table", true)
    validate("git.highlights.Stash", config.highlights.Stash, "table", true)
    validate("git.highlights.Commit", config.highlights.Commit, "table", true)
    validate("git.highlights.Date", config.highlights.Date, "table", true)
  end

  if validate("git.extra", config.extra, "table", true) and config.extra then
    for key, command in vim.spairs(config.extra) do
      validate("git.extra.key", key, "string")
      validate("git.extra." .. key, command, "table")
      validate("git.extra." .. key .. ".cmd", command.cmd, "table")
      validate("git.extra." .. key .. ".show_output", command.show_output, { "boolean", "function" }, true)
      validate("git.extra." .. key .. ".pre_run", command.pre_run, "function", true)
      validate("git.extra." .. key .. ".completions", command.completions, { "table", "function" }, true)
    end
  end

  return #errors == 0, errors
end

return M
