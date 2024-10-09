# Changelog

## [5.0.1](https://github.com/Kibadda/git.nvim/compare/v5.0.0...v5.0.1) (2024-10-09)


### Performance Improvements

* **status:** make components async ([bc48f5c](https://github.com/Kibadda/git.nvim/commit/bc48f5cb7a26ab66aaa678a1216009f60bddb7e6))

## [5.0.0](https://github.com/Kibadda/git.nvim/compare/v4.1.0...v5.0.0) (2024-10-05)


### ⚠ BREAKING CHANGES

* **status:** rename status.status -> status.merge_status

### Features

* **status:** add branch and diff components ([a464d54](https://github.com/Kibadda/git.nvim/commit/a464d546c072616d2c2a7add5007e5c1c0dea446))


### Bug Fixes

* **branch:** wrong completions on empty cmdline ([0e8c548](https://github.com/Kibadda/git.nvim/commit/0e8c54835c61391d4a8790deb6c39a4488bd7e4c))
* **status:** do not calculate diff for buffers with buftype ([3d4269b](https://github.com/Kibadda/git.nvim/commit/3d4269beea12b10d35d8f5c2377b3a392536cbac))


### Code Refactoring

* **status:** rename status.status -&gt; status.merge_status ([621e21c](https://github.com/Kibadda/git.nvim/commit/621e21cbfea27143bfbcee26c7d6e18e80a89098))

## [4.1.0](https://github.com/Kibadda/git.nvim/compare/v4.0.0...v4.1.0) (2024-09-25)


### Features

* add extra config to add custom commands ([dc9de91](https://github.com/Kibadda/git.nvim/commit/dc9de913713e55993a1f776126e71e97d7ee9c32))


### Bug Fixes

* **config:** add missing validate check on highlights ([02f8381](https://github.com/Kibadda/git.nvim/commit/02f83817661c9147c23196956d4bdf9d0b203f07))
* **stash:** wrong prompt for message input ([79328dd](https://github.com/Kibadda/git.nvim/commit/79328dd6c36424327147085625ef4648f2fa5edd))

## [4.0.0](https://github.com/Kibadda/git.nvim/compare/v3.4.0...v4.0.0) (2024-09-18)


### ⚠ BREAKING CHANGES

* **branch:** replace delete command with branch command

### Features

* **branch:** replace delete command with branch command ([7db96e2](https://github.com/Kibadda/git.nvim/commit/7db96e2640b07421acc219a5d6833d3ee3a9f132))
* **buffer:** only use first cmd as name ([1e15eb2](https://github.com/Kibadda/git.nvim/commit/1e15eb2d33453b1037aa2ab9f66456489bfc04e0))
* **commit:** add keymap to show current diff ([1fce2e6](https://github.com/Kibadda/git.nvim/commit/1fce2e644d4f5a5a3a588f32c96cc59e2fbe0681))
* **ui:** add statusline component to show rebase/merge ([b1f1bcc](https://github.com/Kibadda/git.nvim/commit/b1f1bcc72387c3834b7ad89587336b80cbf2f3ca))


### Bug Fixes

* **buffer:** fix nil options and default nospell ([3b80524](https://github.com/Kibadda/git.nvim/commit/3b80524461dead796239a9fb0ea6af264b8c01f7))

## [3.4.0](https://github.com/Kibadda/git.nvim/compare/v3.3.3...v3.4.0) (2024-09-17)


### Features

* **add:** add --edit flag ([ad1138d](https://github.com/Kibadda/git.nvim/commit/ad1138d3f377b919baf61e05a33fa4d199051d6a))
* **config:** add command ([c0ca69b](https://github.com/Kibadda/git.nvim/commit/c0ca69b701949099f4a35c20e942db4fd592be49))
* **diff:** add --cached flag ([6ab597c](https://github.com/Kibadda/git.nvim/commit/6ab597c50b75706e5e5815829678321f7f41c6ce))
* **restore:** add command ([6df7414](https://github.com/Kibadda/git.nvim/commit/6df741486012cb017c93cacf16e83f05220f83a2))
* **status:** add keymap to open file under cursor ([fc95a32](https://github.com/Kibadda/git.nvim/commit/fc95a32bda41d9710a61e0481b36be308b5d280a))


### Bug Fixes

* **editor:** only start insert mode for commit ([ef60beb](https://github.com/Kibadda/git.nvim/commit/ef60beb7c904fa0c867d5995bc6170d778168668))
* **editor:** overwrite q keymap to cancel ([84d74f7](https://github.com/Kibadda/git.nvim/commit/84d74f7e1d533accc4ece61d688bf879ff730d3b))
* remove empty last line in git editor ([d70e4f8](https://github.com/Kibadda/git.nvim/commit/d70e4f8df46ae4ad0e4b67dff20aa08f3b73604d))

## [3.3.3](https://github.com/Kibadda/git.nvim/compare/v3.3.2...v3.3.3) (2024-09-16)


### Bug Fixes

* use proper highlights ([c122de4](https://github.com/Kibadda/git.nvim/commit/c122de4aaa7c3f7c937f87d6682b16d0bc1bca7e))

## [3.3.2](https://github.com/Kibadda/git.nvim/compare/v3.3.1...v3.3.2) (2024-08-19)


### Bug Fixes

* **status:** wrong highlight on first line ([3281a4a](https://github.com/Kibadda/git.nvim/commit/3281a4a587d2d04af6ac1723477cae46ba46f027))

## [3.3.1](https://github.com/Kibadda/git.nvim/compare/v3.3.0...v3.3.1) (2024-08-06)


### Bug Fixes

* **stash:** no need to quote message ([a8869f6](https://github.com/Kibadda/git.nvim/commit/a8869f6d84dd359135da741c29a4782cbdca8d3f))
* **status:** wrong highlight positions ([9c8856e](https://github.com/Kibadda/git.nvim/commit/9c8856e18ee19553553bee52094f22130b9e4381))

## [3.3.0](https://github.com/Kibadda/git.nvim/compare/v3.2.0...v3.3.0) (2024-07-31)


### Features

* **stash:** add message option ([c2d09b8](https://github.com/Kibadda/git.nvim/commit/c2d09b806bbd5a75bc48387f1859936b58913308))

## [3.2.0](https://github.com/Kibadda/git.nvim/compare/v3.1.1...v3.2.0) (2024-07-31)


### Features

* **stash:** add new subcommands ([78ebda2](https://github.com/Kibadda/git.nvim/commit/78ebda2b28416b230ea932f6ff6e1e43ef7a9ee3))


### Bug Fixes

* **editor:** only start insert if line is empty ([7cf9c9e](https://github.com/Kibadda/git.nvim/commit/7cf9c9e7488833d7d736db0368f0d82460b22ad9))
* **output:** replace ^I with spaces ([9f69b8e](https://github.com/Kibadda/git.nvim/commit/9f69b8ee45f2116d1bdb36551246c5ecc85ae163))
* **select:** also apply choice function for single choices ([d924963](https://github.com/Kibadda/git.nvim/commit/d924963192f9a5227f374a97c195c5817fe3484d))

## [3.1.1](https://github.com/Kibadda/git.nvim/compare/v3.1.0...v3.1.1) (2024-07-31)


### Bug Fixes

* **status:** ignored output and fix regex for branch name ([1f484cb](https://github.com/Kibadda/git.nvim/commit/1f484cbb6b015d7b47a48ee3163161646e4d5eb4))

## [3.1.0](https://github.com/Kibadda/git.nvim/compare/v3.0.0...v3.1.0) (2024-07-22)


### Features

* add diff command for files ([1b9b2ee](https://github.com/Kibadda/git.nvim/commit/1b9b2ee98866abc184ea9e017784a5f52234989a))

## [3.0.0](https://github.com/Kibadda/git.nvim/compare/v2.0.0...v3.0.0) (2024-07-22)


### ⚠ BREAKING CHANGES

* simplify config loading/merging

### Features

* add health check ([f9dc2bb](https://github.com/Kibadda/git.nvim/commit/f9dc2bb6e85a2b6631d448401f8aab5f06f5ff98))


### Bug Fixes

* missing status highlight if no upstream branch ([db1678c](https://github.com/Kibadda/git.nvim/commit/db1678c3365b9309dd8063d6d2fc00acf3461fca))


### Code Refactoring

* simplify config loading/merging ([db5f433](https://github.com/Kibadda/git.nvim/commit/db5f433fe1fee41c04e5224469440bb70412fd09))

## [2.0.0](https://github.com/Kibadda/git.nvim/compare/v1.1.0...v2.0.0) (2024-07-18)


### ⚠ BREAKING CHANGES

* open buffer for show_output

### Features

* add highlights for status output ([b045484](https://github.com/Kibadda/git.nvim/commit/b045484074dccd8b83005d7d06596afb06ae6e77))
* add keymap to open diff of commit in log ([5ebaf8c](https://github.com/Kibadda/git.nvim/commit/5ebaf8c0e81dbde7fcabef989ee06052bcec0adf))
* add keymaps to git.buffer.opts ([75b95db](https://github.com/Kibadda/git.nvim/commit/75b95db4cc0ee767896e4df4959cf759693be75d))
* open buffer for show_output ([89e60c2](https://github.com/Kibadda/git.nvim/commit/89e60c2ee0fca4b1dfab8a09eeed947ec767020c))
* remove output from push ([a968b43](https://github.com/Kibadda/git.nvim/commit/a968b43edbd87b3d61231af270839441dac607e6))


### Bug Fixes

* correct name for config ([a3d6ba7](https://github.com/Kibadda/git.nvim/commit/a3d6ba763bf0cbb40614dd460235b44acd956e21))
* use new show_output for log command ([a4589b1](https://github.com/Kibadda/git.nvim/commit/a4589b1049e79344503ca7434ad03ec509e84053))

## [1.1.0](https://github.com/Kibadda/git.nvim/compare/v1.0.0...v1.1.0) (2024-06-07)


### Features

* add log command ([bf3692d](https://github.com/Kibadda/git.nvim/commit/bf3692d11cf35b8d28db930f92c7b11aad0a1829))
* add new commands ([02a821a](https://github.com/Kibadda/git.nvim/commit/02a821a85c92f815ceb127df6c7618e30ea2d553))
* skip some lines in output ([3631e57](https://github.com/Kibadda/git.nvim/commit/3631e57d0c41d9fd6825ca14d0450fc625548d59))


### Bug Fixes

* remove redundant type alias ([c03e7e0](https://github.com/Kibadda/git.nvim/commit/c03e7e08b9bcac95c4351d864d544ecf9dc147ca))
* remove vim.print ([1a0dc8f](https://github.com/Kibadda/git.nvim/commit/1a0dc8fbcb7f261f64a93c40bc9768e463b4378c))
* typing ([3d3f547](https://github.com/Kibadda/git.nvim/commit/3d3f547567deaa4e043f934e5751572ecc16f75b))

## 1.0.0 (2024-06-07)


### Features

* basic functionality ([09e4081](https://github.com/Kibadda/git.nvim/commit/09e40811b44bcd642633080b24b26a429b4b79da))
* initial commit ([06b4466](https://github.com/Kibadda/git.nvim/commit/06b446627fc79d38dbf018f56cf9e97555603b39))
