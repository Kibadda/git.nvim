local M = {}

function M.check()
  vim.health.start "config"

  local config = require "git.config"
  local ok, err = require("git.config.check").validate(config)

  if ok then
    vim.health.ok "no errors found"
  else
    table.insert(err, 1, "there are errors in your config:")
    vim.health.error(table.concat(err, "\n"))
  end
end

return M
