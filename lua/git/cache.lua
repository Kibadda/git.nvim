---@class git.cache
---@field short_branches string[]
---@field full_branches string[]
---@field local_branches string[]
---@field unstaged_files string[]
---@field staged_files string[]
local Cache = setmetatable({}, {
  ---@param self table
  ---@param key "short_branches"|"full_branches"|"local_branches"|"unstaged_files"|"staged_files"
  ---@return string[]
  __index = function(self, key)
    local utils = require "git.utils"

    if key:find "branches" then
      local branches = {}

      local cmd = { "branch", "--column=plain" }

      if key ~= "local_branches" then
        table.insert(cmd, "--all")
      end

      for _, branch in ipairs(utils.git_command(cmd)) do
        if not branch:find "HEAD" and branch ~= "" then
          branch = vim.trim(branch:gsub("*", ""))

          if key == "short_branches" then
            branch = branch:gsub("remotes/[^/]+/", "")
          elseif key == "full_branches" then
            branch = branch:gsub("remotes/", "")
          end

          branches[branch] = true
        end
      end

      self[key] = vim.tbl_keys(branches)
    elseif key == "unstaged_files" then
      local files = {}

      for _, file in ipairs(utils.git_command { "diff", "--name-only" }) do
        files[file] = true
      end
      for _, file in ipairs(utils.git_command { "ls-files", "--others", "--exclude-standard" }) do
        files[file] = true
      end

      self[key] = vim.tbl_keys(files)
    elseif key == "staged_files" then
      self[key] = utils.git_command { "diff", "--cached", "--name-only" }
    end

    return self[key]
  end,
})

return Cache
