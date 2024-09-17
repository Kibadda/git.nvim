# git.nvim

## Configuration
To change the default configuration, set `vim.g.git`.

Default config:
```lua
vim.g.git = {
  editor = {
    spell = {
      commit = true,
      rebase = false,
    },
    window_config = {
      split = "below",
      win = 0,
      height = 20,
    },
    treesitter = true,
    cancel = "<C-c>",
  },
  highlights = {
    Branch = { fg = "#7daea3" },
    Upstream = { fg = "#7daea3" },
    Untracked = { fg = "#ea6962" },
    Unstaged = { fg = "#ea6962" },
    Commited = { fg = "#a9b665" },
    Command = { fg = "#d8a657" },
    Stash = { fg = "#d8a657" },
    Commit = { fg = "#ea6962" },
    Date = { fg = "#a9b665" },
  }
}
```

## Usage
This plugin provides a user command `Git`. Supported git functionality:
- status
- add
- commit
- push
- pull
- switch
- fetch
- rebase
- merge
- stash
- reset
- branch --delete
- log
- diff
- restore
- config

Supported options on each command can be seen in the completions.

This plugin sets the GIT_EDITOR variable so that commit messages can be edited in the current nvim instance.
