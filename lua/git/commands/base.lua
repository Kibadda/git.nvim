---@class git.command.options
---@field cmd string[]
---@field show_output? boolean|fun(self: git.command, opts: git.buffer.opts)
---@field pre_run? fun(self: git.command, fargs: string[]): boolean?
---@field completions? string[]|fun(fargs: string[]): string[]

---@class git.command : git.command.options
---@field new fun(opts: git.command.options): git.command
---@field run fun(self: git.command, fargs: string[])
---@field complete fun(self: git.command, arg_lead: string): string[]
---@field post_run fun(self: git.command, stdout: string[])
local M = {}
M.__index = M

for name, hl in pairs(require("git.config").highlights) do
  vim.api.nvim_set_hl(0, "Git" .. name, hl)
end

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
        vim.notify(table.concat(stdout, "\n"):gsub("	", string.rep(" ", 8)), vim.log.levels.ERROR)
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
  if not self.show_output then
    vim.api.nvim_echo({ { "Done: " .. table.concat(self.cmd, " "), "WarningMsg" } }, true, {})
  else
    local skips = {
      "Compressing objects",
      "Counting objects",
      "Resolving deltas",
      "Unpacking objects",
      "Writing objects",
      "Receiving objects",
      "Enumerating objects",
      "Refresh index",
    }

    local lines = {}

    for _, line in ipairs(stdout) do
      local should_skip = false

      for _, skip in ipairs(skips) do
        if line:find(skip) then
          should_skip = true
          break
        end
      end

      if not should_skip then
        table.insert(lines, line)
      end
    end

    ---@type git.buffer.opts
    local options = {
      name = table.concat(self.cmd, " "),
      lines = lines,
      options = {
        modifiable = false,
        modified = false,
      },
    }

    if type(self.show_output) == "function" then
      self:show_output(options)
    end

    require("git.utils").open_buffer(options)
  end
end

function M.new(opts)
  return setmetatable(opts, M) --[[@as git.command]]
end

return M
