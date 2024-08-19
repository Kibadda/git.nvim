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

Supported options on each command can be seen in the completions.

This plugin sets the GIT_EDITOR variable so that commit messages can be edited in the current nvim instance.
