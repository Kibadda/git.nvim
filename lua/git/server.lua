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

  local filetype, spell, startinsert
  if file:find "COMMIT_EDITMSG" or file:find "MERGE_MSG" then
    filetype = "gitcommit"
    startinsert = true
    spell = config.editor.spell.commit
  elseif file:find "git%-rebase%-todo" then
    filetype = "git_rebase"
    spell = config.editor.spell.rebase
  elseif file:find "ADD_EDIT.patch" then
    filetype = "diff"
  end

  local cancel = false

  local _, bufnr = require("git.utils").open_buffer {
    name = file,
    lines = readlines(file),
    options = {
      filetype = filetype,
      bufhidden = "wipe",
      spell = spell,
    },
    treesitter = config.editor.treesitter,
    keymaps = {
      {
        mode = { "i", "n" },
        lhs = config.editor.cancel,
        rhs = function(bufnr)
          cancel = true
          vim.cmd.stopinsert()
          vim.api.nvim_buf_delete(bufnr, { force = true })
        end,
      },
      {
        mode = "n",
        lhs = "q",
        rhs = function(bufnr)
          cancel = true
          vim.cmd.stopinsert()
          vim.api.nvim_buf_delete(bufnr, { force = true })
        end,
      },
    },
  }

  vim.api.nvim_buf_call(bufnr, function()
    vim.cmd.w { bang = true }
    if startinsert and vim.api.nvim_get_current_line() == "" then
      vim.cmd.startinsert()
    end
  end)

  vim.api.nvim_buf_attach(bufnr, false, {
    on_detach = function()
      pcall(vim.treesitter.stop, bufnr)

      vim.rpcnotify(socket, "nvim_command", cancel and "cq" or "qall")

      vim.fn.chanclose(socket)
    end,
  })
end

return M
