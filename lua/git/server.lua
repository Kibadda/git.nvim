local M = {}

---@param path string
local function readlines(path)
  local handle = assert(io.open(path), "could not open file at path: " .. path)

  local lines = handle:read "a"

  return vim.split(lines, "\n")
end

---@param file string
---@param client string
function M.open(file, client)
  vim.print(file, client)
  local socket = vim.fn.sockconnect("pipe", client, { rpc = true })

  local bufnr = vim.api.nvim_create_buf(false, false)
  vim.api.nvim_buf_set_name(bufnr, file)

  local config = require("git.config").get()

  local filetype, spell
  if file:find "COMMIT_EDITMSG" or file:find "MERGE_MSG" then
    filetype = "gitcommit"
    spell = config.editor.spell.commit
  elseif file:find "git%-rebase%-todo" then
    filetype = "git_rebase"
    spell = config.editor.spell.rebase
  end

  vim.bo[bufnr].bufhidden = "wipe"
  vim.bo[bufnr].filetype = filetype

  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, readlines(file))
  vim.api.nvim_buf_call(bufnr, function()
    vim.cmd.w { bang = true }
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
  end)

  if config.editor.treesitter then
    local ok = pcall(vim.treesitter.language.inspect, filetype)
    if ok then
      vim.treesitter.start(bufnr, filetype)
    end
  end

  local win = vim.api.nvim_open_win(bufnr, true, config.editor.window_config)

  if spell then
    vim.wo[win].spell = true
  end
end

return M
