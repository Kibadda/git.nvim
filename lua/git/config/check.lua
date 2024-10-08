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
    highlights = { config.highlights, "table", true },
    extra = { config.extra, "table", true },
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

  ok, err = validate("git.highlights", {
    Branch = { config.highlights.Branch, "table", true },
    Upstream = { config.highlights.Upstream, "table", true },
    Untracked = { config.highlights.Untracked, "table", true },
    Unstaged = { config.highlights.Unstaged, "table", true },
    Commited = { config.highlights.Commited, "table", true },
    Command = { config.highlights.Command, "table", true },
    Stash = { config.highlights.Stash, "table", true },
    Commit = { config.highlights.Commit, "table", true },
    Date = { config.highlights.Date, "table", true },
  })
  if not ok then
    return false, err
  end

  for key, command in vim.spairs(config.extra or {}) do
    ok, err = validate("git.extra." .. key, {
      key = { key, "string" },
      command = { command, "table" },
    })
    if not ok then
      return false, err
    end

    ok, err = validate("git.extra." .. key, {
      cmd = { command.cmd, "table" },
      show_output = { command.show_output, { "boolean", "function" }, true },
      pre_run = { command.pre_run, "function", true },
      completions = { command.completions, { "table", "function" }, true },
    })
    if not ok then
      return false, err
    end
  end

  return true
end

return M
