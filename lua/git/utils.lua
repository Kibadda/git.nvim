local M = {}

local ns = vim.api.nvim_create_namespace "GitNvim"

---@param cmd string[]
function M.git_command(cmd)
  local result = vim.system(vim.list_extend({ "git", "--no-pager" }, cmd)):wait()

  return vim.split(result.stdout, "\n")
end

---@param opts { cmd: string[], prompt: string, decode?: function, format?: function, choice?: function }
---@return string?
local function select(opts)
  local lines = {}

  for _, line in ipairs(M.git_command(opts.cmd)) do
    if line ~= "" then
      table.insert(lines, opts.decode and opts.decode(line) or line)
    end
  end

  if #lines <= 1 then
    return lines[1]
  end

  local choice

  vim.ui.select(lines, {
    prompt = opts.prompt,
    format_item = opts.format,
  }, function(item)
    choice = opts.choice and opts.choice(item) or item
  end)

  return choice
end

function M.select_commit()
  return select {
    cmd = { "log", "--pretty=%h|%s" },
    prompt = "Commit",
    decode = function(line)
      return vim.split(line, "|")
    end,
    format = function(item)
      return item[2]
    end,
    choice = function(item)
      return item and item[1] or nil
    end,
  }
end

function M.select_remote()
  return select {
    cmd = { "remote" },
    prompt = "Remote",
  }
end

---@class git.buffer.opts
---@field name? string
---@field lines? string[]
---@field options? table
---@field treesitter? boolean
---@field extmarks? table
---@field keymaps? table

---@param opts git.buffer.opts
function M.open_buffer(opts)
  local config = require "git.config"

  local bufnr = vim.api.nvim_create_buf(false, false)
  vim.api.nvim_buf_set_name(bufnr, opts.name or "git")
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, opts.lines or {})

  local win = vim.api.nvim_open_win(bufnr, true, config.editor.window_config)

  vim.keymap.set("n", "q", function()
    vim.api.nvim_buf_delete(bufnr, { force = true })
  end, { buffer = bufnr })

  for k, v in pairs(opts.options) do
    local info = vim.api.nvim_get_option_info2(k, {})
    if info.scope == "buf" then
      vim.bo[bufnr][k] = v
    else
      vim.wo[win][k] = v
    end
  end

  if opts.treesitter and opts.options and opts.options.filetype then
    pcall(vim.treesitter.start, bufnr, opts.options.filetype)
  end

  if opts.extmarks then
    for _, extmark in ipairs(opts.extmarks) do
      vim.api.nvim_buf_set_extmark(bufnr, ns, extmark.line - 1, extmark.col - 1, {
        end_col = extmark.end_col,
        hl_group = extmark.hl,
      })
    end
  end

  if opts.keymaps then
    for _, keymap in ipairs(opts.keymaps) do
      vim.keymap.set(keymap.mode, keymap.lhs, function()
        keymap.rhs(bufnr, win)
      end, vim.tbl_extend("error", { buffer = bufnr }, keymap.opts or {}))
    end
  end

  return win, bufnr
end

return M
