local M = {}

---@param path string
local function readlines(path)
  local handle = assert(io.open(path), "could not open file at path: " .. path)

  local lines = vim.split(handle:read "a", "\n")
  lines[#lines] = nil

  return lines
end

---@param file string
---@param client string
function M.open(file, client)
  local socket = vim.fn.sockconnect("pipe", client, { rpc = true })

  local config = require "git.config"

  local filetype, spell
  if file:find "COMMIT_EDITMSG" or file:find "MERGE_MSG" then
    filetype = "gitcommit"
    spell = config.editor.spell.commit
  elseif file:find "git%-rebase%-todo" then
    filetype = "git_rebase"
    spell = config.editor.spell.rebase
  elseif file:find "ADD_EDIT.patch" then
    filetype = "diff"
  end

  local _, bufnr = require("git.utils").open_buffer {
    name = file,
    lines = readlines(file),
    options = {
      filetype = filetype,
      bufhidden = "wipe",
      spell = spell,
    },
    treesitter = config.editor.treesitter,
  }

  vim.api.nvim_buf_call(bufnr, function()
    vim.cmd.w { bang = true }
    if vim.api.nvim_get_current_line() == "" then
      vim.cmd.startinsert()
    end
  end)

  local cancel = false

  vim.api.nvim_buf_attach(bufnr, false, {
    on_detach = function()
      pcall(vim.treesitter.stop, bufnr)

      vim.rpcnotify(socket, "nvim_command", cancel and "cq" or "qall")

      vim.fn.chanclose(socket)
    end,
  })

  vim.keymap.set({ "i", "n" }, config.editor.cancel, function()
    cancel = true
    vim.cmd.stopinsert()
    vim.api.nvim_buf_delete(bufnr, { force = true })
  end, { buffer = bufnr, desc = "Cancel" })
end

return M
