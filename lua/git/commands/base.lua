---@class git.command.options
---@field cmd string[]
---@field show_output? boolean
---@field pre_run? fun(self: git.command, fargs: string[]): boolean?
---@field post_run? fun(self: git.command, stdout: string[])
---@field complete? fun(self: git.command, arg_lead: string): string[]
---@field completions? string[]|fun(fargs: string[]): string[]

---@class git.command : git.command.options
---@field run fun(self: git.command, fargs: string[])
local M = {}
M.__index = M

local client_path

function M:run(fargs)
  local cmd = vim.list_extend({
    "git",
    "--no-pager",
    "-c",
    "color.ui=never",
  }, self.cmd)

  if self.pre_run then
    if self:pre_run(fargs) == false then
      return
    end
  end

  local line = ""
  local stdout = {}

  if not client_path or not vim.fn.filereadable(client_path) == 0 then
    client_path = vim.fn.tempname()
    vim.fn.writefile({
      "lua << EOF",
      string.format("local socket = vim.fn.sockconnect('pipe', '%s', { rpc = true })", vim.v.servername),
      [[local cmd = string.format('require("git.server").open("%s", "%s")', vim.fn.argv(0), vim.v.servername)]],
      "vim.rpcrequest(socket, 'nvim_exec_lua', cmd, {})",
      "EOF",
    }, client_path)
  end

  vim.fn.jobstart(vim.list_extend(cmd, fargs), {
    cwd = vim.fn.getcwd(),
    env = {
      GIT_EDITOR = vim.v.progpath .. " --headless --clean -u " .. client_path,
    },
    pty = true,
    width = 80,
    on_stdout = function(_, lines)
      line = line .. lines[1]:gsub("\r", "")

      for i = 2, #lines do
        table.insert(stdout, line)
        line = lines[i]:gsub("\r", "")
      end
    end,
    on_exit = function(_, code)
      if line ~= "" then
        table.insert(stdout, line)
      end

      if code ~= 0 then
        vim.notify(table.concat(stdout, "\n"), vim.log.levels.ERROR)
      else
        self:post_run(stdout)
      end
    end,
  })
end

function M:complete(arg_lead)
  local split = vim.split(arg_lead, "%s+")

  local completions = self.completions or {}

  if type(completions) == "function" then
    completions = completions(split)
  end

  ---@type string[]
  local complete = vim.tbl_filter(function(opt)
    if vim.tbl_contains(split, opt) then
      return false
    end

    return string.find(opt, "^" .. split[#split]:gsub("%-", "%%-")) ~= nil
  end, completions)

  table.sort(complete)

  return complete
end

function M:post_run(stdout)
  local output = {
    { "Done: " .. table.concat(self.cmd, " "), "WarningMsg" },
  }

  if self.show_output then
    for _, line in ipairs(stdout) do
      table.insert(output, { "\n" .. line })
    end
  end

  vim.api.nvim_echo(output, true, {})
end

---@param opts git.command.options
function M.new(opts)
  return setmetatable(opts, M) --[[@as git.command]]
end

return M
