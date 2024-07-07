# Changelog

## [2.0.0](https://github.com/folke/flash.nvim/compare/v1.18.3...v2.0.0) (2024-07-05)


### ⚠ BREAKING CHANGES

* **search:** flash is now no longer enabled by default during search. Enable it in your config, or use toggle.

### Features

* **char:** add auto-jump/auto-motion option when using labels, closes [#183](https://github.com/folke/flash.nvim/issues/183) ([#281](https://github.com/folke/flash.nvim/issues/281)) ([b14120a](https://github.com/folke/flash.nvim/commit/b14120a4b55c34a83baf40650b8612b411c81ef4))
* **search:** flash is now no longer enabled by default during search. Enable it in your config, or use toggle. ([2411de6](https://github.com/folke/flash.nvim/commit/2411de6fd773ab5b902cf04f2dccfe3baadff229))


### Bug Fixes

* Don't exit in regular search mode when there is no result ([#277](https://github.com/folke/flash.nvim/issues/277)) ([518c047](https://github.com/folke/flash.nvim/commit/518c047031e3dee0b22fad2b23d75deb7ecd826e))
* use real cursors on Neovim &gt;= 0.10. See [#345](https://github.com/folke/flash.nvim/issues/345) ([7ba2298](https://github.com/folke/flash.nvim/commit/7ba2298eb196826442ce68cc6ec0cae2d7d4dbe1))

## [1.18.3](https://github.com/folke/flash.nvim/compare/v1.18.2...v1.18.3) (2024-05-03)


### Bug Fixes

* **hacks:** use `vim.api.nvim__redraw` to fix the cursor instead of ffi. Fixes [#333](https://github.com/folke/flash.nvim/issues/333) ([1b128ff](https://github.com/folke/flash.nvim/commit/1b128ff527c3938460ef83fe6403ce6ce3f53b53))

## [1.18.2](https://github.com/folke/flash.nvim/compare/v1.18.1...v1.18.2) (2023-10-17)


### Bug Fixes

* **treesitter:** show warning when treesitter not available. Fixes [#261](https://github.com/folke/flash.nvim/issues/261) ([77c66d8](https://github.com/folke/flash.nvim/commit/77c66d84be3e2a2ef2e6689de668fe156af74498))

## [1.18.1](https://github.com/folke/flash.nvim/compare/v1.18.0...v1.18.1) (2023-10-16)


### Bug Fixes

* **char:** allow setting autohide=true for char mode. Fixes [#231](https://github.com/folke/flash.nvim/issues/231) ([71040c8](https://github.com/folke/flash.nvim/commit/71040c87bd64d2719727006f51f8679352eb6146))
* **jump:** send `esc` when cancelling flash. Fixes [#212](https://github.com/folke/flash.nvim/issues/212). Fixes [#233](https://github.com/folke/flash.nvim/issues/233) ([677eb59](https://github.com/folke/flash.nvim/commit/677eb59f0a94ed3b735168d9e6738723fd44796d))
* **treesitter:** include treesitter injections. Fixes [#242](https://github.com/folke/flash.nvim/issues/242) ([5fe47ba](https://github.com/folke/flash.nvim/commit/5fe47baf1be05ea34abb6912ed89a5a17cbf5661))
* **treesitter:** keep treesitter sorting when doing ;,. Fixes [#219](https://github.com/folke/flash.nvim/issues/219) ([aae8352](https://github.com/folke/flash.nvim/commit/aae83521091fac904b8584bb2dffe13420b7adc7))

## [1.18.0](https://github.com/folke/flash.nvim/compare/v1.17.3...v1.18.0) (2023-10-02)


### Features

* **char:** allow disabling clever-f motions. Fixes [#245](https://github.com/folke/flash.nvim/issues/245) ([bc1f49f](https://github.com/folke/flash.nvim/commit/bc1f49f428655b645948a3489bf0efcded6f46e6))
* enable multi window in vscode ([#230](https://github.com/folke/flash.nvim/issues/230)) ([65bd3ee](https://github.com/folke/flash.nvim/commit/65bd3ee715229fecdb5a9727e8dcd099c187622b))
* **highlight:** allow overriding flash cursor hl. Fixes [#228](https://github.com/folke/flash.nvim/issues/228) ([79d67c6](https://github.com/folke/flash.nvim/commit/79d67c6d29cd3d784eb5f1410ba057e1f1499fe9))


### Bug Fixes

* **char:** disable jump labels when reg recording/executing ([#226](https://github.com/folke/flash.nvim/issues/226)) ([503b0ab](https://github.com/folke/flash.nvim/commit/503b0ab0091776d2c40541507114ff4b2f24f5b9))
* **jump:** only open folds containing match. Fixes [#224](https://github.com/folke/flash.nvim/issues/224). Fixes [#225](https://github.com/folke/flash.nvim/issues/225) ([a74d31f](https://github.com/folke/flash.nvim/commit/a74d31ffec4a6e9feb6adc33efdba247d5d912f0))
* **search:** allow disabling multi window for search. Fixes [#198](https://github.com/folke/flash.nvim/issues/198). Fixes [#197](https://github.com/folke/flash.nvim/issues/197) ([0256d8e](https://github.com/folke/flash.nvim/commit/0256d8ecab33a9aa69fdaaf885db22e1103e2a3a))
* **state:** use actions instead of opts.actions ([30442c8](https://github.com/folke/flash.nvim/commit/30442c88b817b5d00fcbe2f88977bbd5d0221a20))

## [1.17.3](https://github.com/folke/flash.nvim/compare/v1.17.2...v1.17.3) (2023-07-20)


### Bug Fixes

* **jump:** disable operator keymaps when replaying remote. Fixes [#165](https://github.com/folke/flash.nvim/issues/165) ([9f30d48](https://github.com/folke/flash.nvim/commit/9f30d48e2f509723e59c5b0915f343ce297cf386))

## [1.17.2](https://github.com/folke/flash.nvim/compare/v1.17.1...v1.17.2) (2023-07-18)


### Bug Fixes

* **char:** only use c for first search (of count) when current=true ([c92ecbf](https://github.com/folke/flash.nvim/commit/c92ecbff98fdc8770c283aa3934349e6889195dd))
* **config:** run `setup` when using flash and it wasn't run yet. Fixes [#162](https://github.com/folke/flash.nvim/issues/162) ([c81e0d1](https://github.com/folke/flash.nvim/commit/c81e0d11b9e6e1279321e12a5d87dd3fac593854))
* **state:** feed char when incremental and no match. Fixes [#57](https://github.com/folke/flash.nvim/issues/57) ([925f733](https://github.com/folke/flash.nvim/commit/925f733a731f8ed351e47d434e3a353995761012))

## [1.17.1](https://github.com/folke/flash.nvim/compare/v1.17.0...v1.17.1) (2023-07-16)


### Bug Fixes

* **char:** fix current for tT when count=0. Fixes [#159](https://github.com/folke/flash.nvim/issues/159) ([8604b56](https://github.com/folke/flash.nvim/commit/8604b562d919772dc161ac831dd7bfa948833fdd))
* **char:** never add mappings for mapleader and maplocalleader ([6e3dab6](https://github.com/folke/flash.nvim/commit/6e3dab6b011bb7661b16e14dd4aa4215894c9291))
* **char:** never overwrite existing mappings for ; and , ([abda6b8](https://github.com/folke/flash.nvim/commit/abda6b848bb11051e6a789f8a8572da3d3840bf1))
* **char:** reset including current for tT searches. Fixes [#152](https://github.com/folke/flash.nvim/issues/152) ([9c53dad](https://github.com/folke/flash.nvim/commit/9c53dad391801acb9ce9aa49820f15f6692aec91))
* **highlight:** set hl of target to current if it's a single character only. See [#158](https://github.com/folke/flash.nvim/issues/158) ([47d147b](https://github.com/folke/flash.nvim/commit/47d147b9527025b2ee73631b098edb5798afef4b))
* **remote:** properly pass register for remote ops. Fixes [#156](https://github.com/folke/flash.nvim/issues/156) ([34cf6f6](https://github.com/folke/flash.nvim/commit/34cf6f685d2eabc8de438fdbaa41c8c17e9da459))

## [1.17.0](https://github.com/folke/flash.nvim/compare/v1.16.0...v1.17.0) (2023-07-14)


### Features

* **labels:** allow disabling reusing labels. Closes [#147](https://github.com/folke/flash.nvim/issues/147) ([4b73e61](https://github.com/folke/flash.nvim/commit/4b73e6124f4e9b44713cb85ec5db3809923d2374))


### Bug Fixes

* **char:** properly exit op mode when doing esc with ftFT and jump labels ([4731cc4](https://github.com/folke/flash.nvim/commit/4731cc47459f66f9a73d19e11ea157e105384fd6))
* **char:** set inclusive=false for FT. Fixes [#149](https://github.com/folke/flash.nvim/issues/149) ([b1af2b7](https://github.com/folke/flash.nvim/commit/b1af2b78b30e814c08840a5bb7f7ccef726ea771))
* **jump:** better way to cancel operator pending mode ([4a980ea](https://github.com/folke/flash.nvim/commit/4a980ea7fedf20c902375fe7aa1141d671b0ffa7))

## [1.16.0](https://github.com/folke/flash.nvim/compare/v1.15.0...v1.16.0) (2023-07-12)


### Features

* **fold:** show first label inside a fold on the folded text line. Fixes [#39](https://github.com/folke/flash.nvim/issues/39) ([2846324](https://github.com/folke/flash.nvim/commit/28463247f21a6e0b5486dc6d31c7ace0e43a4877))
* **jump:** open folds when jumping to a folded position. See [#39](https://github.com/folke/flash.nvim/issues/39) ([dcb494c](https://github.com/folke/flash.nvim/commit/dcb494cfa79aae32e17a44026591564793b75434))
* **search:** when nohlsearch=false, matches will now be shown after jump. Fixes [#142](https://github.com/folke/flash.nvim/issues/142) ([6e7d6c2](https://github.com/folke/flash.nvim/commit/6e7d6c26a4528a8d6a17e2d23c3f5738491d736d))


### Bug Fixes

* **repeat:** no dot repeat inside macros. Fixes [#143](https://github.com/folke/flash.nvim/issues/143) ([f7218c2](https://github.com/folke/flash.nvim/commit/f7218c2d44a8d67c5c4b40edd569c55f95754354))

## [1.15.0](https://github.com/folke/flash.nvim/compare/v1.14.0...v1.15.0) (2023-07-07)


### Features

* **search:** flash toggle in search is now permanent until you toggle again. Closes [#134](https://github.com/folke/flash.nvim/issues/134) ([7ceee0d](https://github.com/folke/flash.nvim/commit/7ceee0de7e96c7453d5f82dcfc938f08d8029703))


### Bug Fixes

* **char:** special handling for t/T at current position. Fixes [#137](https://github.com/folke/flash.nvim/issues/137) ([268bffe](https://github.com/folke/flash.nvim/commit/268bffe7b9b1b9a3a4bb64a5bc8ac0627b4b7c14))

## [1.14.0](https://github.com/folke/flash.nvim/compare/v1.13.2...v1.14.0) (2023-07-05)


### Features

* **char:** added optional multi_line=false for ftFT motions. See [#102](https://github.com/folke/flash.nvim/issues/102) ([2f92418](https://github.com/folke/flash.nvim/commit/2f924186255a56cab4cf22e13b0bc1fb906b11fa))
* **char:** option for behavior of ;, and char repeats. Closes [#124](https://github.com/folke/flash.nvim/issues/124) ([97eba7d](https://github.com/folke/flash.nvim/commit/97eba7df4454097c1f6cc447de2a4e9230831ffb))
* **search:** allow finding current ([6659a94](https://github.com/folke/flash.nvim/commit/6659a94a033c2f6fec1e142451aa264f03e5da90))
* **state:** added optional `filter` for matches by non-search matcher. See [#118](https://github.com/folke/flash.nvim/issues/118) ([780ad57](https://github.com/folke/flash.nvim/commit/780ad57dedb464bfe8361356959b3ac5aaed533d))
* **treesitter:** added `node:TSNode` to ts `Flash.Match.TS` ([1cbaff4](https://github.com/folke/flash.nvim/commit/1cbaff4a7f074c1121c89207210e4588321acd40))


### Bug Fixes

* **char:** fixed tT at current. Fixes [#128](https://github.com/folke/flash.nvim/issues/128) ([a1c8aa6](https://github.com/folke/flash.nvim/commit/a1c8aa62204d5eb2036e819f5b919b1fe4b88918))
* **jump:** move offset calc outside op mode ([69141ea](https://github.com/folke/flash.nvim/commit/69141ea571602a9202ad51fae1cfe7c1894fe036))
* **search:** count=0 ([6d1d066](https://github.com/folke/flash.nvim/commit/6d1d066e6b5fcc2ed3ca446d229c0a0d306acf17))
* take into count of multi-width characters on offset of highlights and jump ([#125](https://github.com/folke/flash.nvim/issues/125)) ([41c09fa](https://github.com/folke/flash.nvim/commit/41c09faf8588887c7c15d8ca63c9ede805437da2))

## [1.13.2](https://github.com/folke/flash.nvim/compare/v1.13.1...v1.13.2) (2023-07-02)


### Bug Fixes

* **highlight:** dont use current when rainbow is used and match == target. Fixes [#109](https://github.com/folke/flash.nvim/issues/109) ([edb82f7](https://github.com/folke/flash.nvim/commit/edb82f763ac2b63006154e9da8b6629b570de551))

## [1.13.1](https://github.com/folke/flash.nvim/compare/v1.13.0...v1.13.1) (2023-07-02)


### Bug Fixes

* **config:** dont show jumpt labels by default! Fixup. See [#103](https://github.com/folke/flash.nvim/issues/103) ([7bb89b2](https://github.com/folke/flash.nvim/commit/7bb89b20fd42037c1cd7ed8d3193081d86f8c39b))
* **highlight:** don't show the label when at cursor in same window and not a range. See [#74](https://github.com/folke/flash.nvim/issues/74) ([7a8e07e](https://github.com/folke/flash.nvim/commit/7a8e07e62ad1a378d6eca958aad90fc071d14e9c))
* **labeler:** don't label folded lines. Fixes [#39](https://github.com/folke/flash.nvim/issues/39). See [#106](https://github.com/folke/flash.nvim/issues/106) ([8af3773](https://github.com/folke/flash.nvim/commit/8af3773b7b960b053038868ea18867b94abae9c8))

## [1.13.0](https://github.com/folke/flash.nvim/compare/v1.12.0...v1.13.0) (2023-07-01)


### Features

* **config:** added `opts.config` for dynamically configuring flash. Closes [#103](https://github.com/folke/flash.nvim/issues/103) ([3829d81](https://github.com/folke/flash.nvim/commit/3829d81fd6f5f6ca784bb9628a1b99298b88a3af))


### Bug Fixes

* **state:** use strchars instead of strcharlen for compat 0.8.2. Fixes [#105](https://github.com/folke/flash.nvim/issues/105) ([33e0793](https://github.com/folke/flash.nvim/commit/33e0793a614735a3fffb93763c4c9bd81b55433b))

## [1.12.0](https://github.com/folke/flash.nvim/compare/v1.11.0...v1.12.0) (2023-06-30)


### Features

* **state:** added support for custom keymaps and lmap. See [#66](https://github.com/folke/flash.nvim/issues/66) ([9aa7805](https://github.com/folke/flash.nvim/commit/9aa78057cf13dde3d39bf25cfe5caf092083cc0c))


### Bug Fixes

* **labeler:** fixed calculating skip labels for mbyte keymaps. See [#66](https://github.com/folke/flash.nvim/issues/66) ([2da635f](https://github.com/folke/flash.nvim/commit/2da635f54b81538a1e12b4859bc292d7d3e5f1b9))
* **treesitter:** added support for Nvim 0.8.0. Fixes [#100](https://github.com/folke/flash.nvim/issues/100) ([67ed44d](https://github.com/folke/flash.nvim/commit/67ed44d5efd2d05b49af861859740eedf3a076b6))
* **treesitter:** some nodes were missing ([7f4e25f](https://github.com/folke/flash.nvim/commit/7f4e25fae0fa1d3adfeb3e3e87fba9ff914032a0))

## [1.11.0](https://github.com/folke/flash.nvim/compare/v1.10.1...v1.11.0) (2023-06-29)


### Features

* **char:** hide flash when doing an ftFT search while yanking. Closes [#6](https://github.com/folke/flash.nvim/issues/6) ([feda1d5](https://github.com/folke/flash.nvim/commit/feda1d5a98a1705e86966e62a052661a7369b3c0))
* **char:** optional jump labels for ftFT searches ([d2ad5e0](https://github.com/folke/flash.nvim/commit/d2ad5e0d776a89ee424a7e0cd4364ec5dbf11dc4))
* **char:** support alternative f/F/t/T/;/, keymaps (fix [#96](https://github.com/folke/flash.nvim/issues/96)) ([#99](https://github.com/folke/flash.nvim/issues/99)) ([c0c006a](https://github.com/folke/flash.nvim/commit/c0c006a7bb694b4cec9a5f40e632f871b478e0d0))
* **label:** added `opts.label.format` for formatting rendered labels. Closes [#84](https://github.com/folke/flash.nvim/issues/84) ([2d3e7b9](https://github.com/folke/flash.nvim/commit/2d3e7b90c568083e9857b100dc2570d269da0a0c))
* **labeler:** allow excluding certain labels with a specific case ([6b255d3](https://github.com/folke/flash.nvim/commit/6b255d37505445da3db6fae5d79dff63529cd222))
* **pos:** Pos can now be initialized with window or current window cursor ([7a05cd5](https://github.com/folke/flash.nvim/commit/7a05cd5dadb78b8d475526157e464f24d14ff5b2))
* **search:** you can now `toggle` flash while using regular search ([e761182](https://github.com/folke/flash.nvim/commit/e761182f6c79ff5f88c877729465ece05b01c65a))
* **state:** custom char actions ([4f44bb4](https://github.com/folke/flash.nvim/commit/4f44bb454df0c6f598e75cd8501a1eb8e1bd2df5))


### Bug Fixes

* **hacks:** make sure to render the cursor before getchar ([2b328d1](https://github.com/folke/flash.nvim/commit/2b328d121c2b56cf25e1eb9ba92c7459beb241be))
* **highlight:** never put an extmark on the current cursor position ([8434130](https://github.com/folke/flash.nvim/commit/843413028843d1c3ce29449fe9ff62af8f642540))
* **highlight:** use current hl if pos == label pos ([56531ee](https://github.com/folke/flash.nvim/commit/56531ee85d919e787dbb247aabedb5d3dd0b7bd1))
* **jump:** replace opfunc by noop to properly cancel custom operators. Fixes [#93](https://github.com/folke/flash.nvim/issues/93) ([40b2bcb](https://github.com/folke/flash.nvim/commit/40b2bcbb05f1452f2ee7d21b79ce8ba77ea6cc94))
* **jump:** temporarily set selection=inclusive. Closes [#81](https://github.com/folke/flash.nvim/issues/81) ([5c9505a](https://github.com/folke/flash.nvim/commit/5c9505a19edcbb236d367282584ed5f02ccd4fb4))
* **labeler:** fixed label distance calculation ([1d941de](https://github.com/folke/flash.nvim/commit/1d941de722564a8ac2f07c2df262a48c49c1cdb9))
* **labeler:** put original pattern in a `\%()` group. Fixes some skip label issues ([6102a7c](https://github.com/folke/flash.nvim/commit/6102a7c0e93dbcf592a7ed2b7a2a5c2a84c5033e))
* **labeler:** skip all labels on invalid regex. Fixes [#94](https://github.com/folke/flash.nvim/issues/94) ([1fff746](https://github.com/folke/flash.nvim/commit/1fff746049253b10a008d60e1752065a98fd8614))
* **remote:** use nvim_input instead of nvim_feedkeys for clearing op mode ([c90eae5](https://github.com/folke/flash.nvim/commit/c90eae5172a00551d51883cf8b67306a812a713f))
* **search:** correctly set match end pos for multi byte characters. Fixes [#90](https://github.com/folke/flash.nvim/issues/90) ([0193d52](https://github.com/folke/flash.nvim/commit/0193d52af38d228b79569c62e06ee36b77a1a85e))
* **treesitter:** ignore windows without ts parser. Fixes [#91](https://github.com/folke/flash.nvim/issues/91) ([13022c0](https://github.com/folke/flash.nvim/commit/13022c09fa30fb03d14110a380238f6a75b42ab4))

## [1.10.1](https://github.com/folke/flash.nvim/compare/v1.10.0...v1.10.1) (2023-06-27)


### Bug Fixes

* **highlight:** apply after labels and then before ([4439fca](https://github.com/folke/flash.nvim/commit/4439fca240a54ef4d4537102668285e9cbb6f23c))
* **highlight:** correctly order after labels at the same column ([b096797](https://github.com/folke/flash.nvim/commit/b096797b64f56357c40222f5a3cff6f25ac3b5dc))
* **highlight:** make sure col is not negative with label.before = true ([cbce7f9](https://github.com/folke/flash.nvim/commit/cbce7f923c74fb75be030273c0d49f6a3447a95f))
* **prompt:** never show the prompt when in regular search ([51149ba](https://github.com/folke/flash.nvim/commit/51149ba2e6bcba0a28e67b9654450835437a2914))
* **rainbow:** stable rainbow label highlight groups ([937df4f](https://github.com/folke/flash.nvim/commit/937df4f097781e3e91594bf69425f3e74044b711))

## [1.10.0](https://github.com/folke/flash.nvim/compare/v1.9.0...v1.10.0) (2023-06-27)


### Features

* **highlight:** added optional rainbow labels. Disabled by default. Useful for Treesitter ranges. ([#74](https://github.com/folke/flash.nvim/issues/74)) ([ffb865b](https://github.com/folke/flash.nvim/commit/ffb865b1a60732d9ce2c9bffe3fb6724e1004ebb))


### Bug Fixes

* **char:** force before=false with f, F motion ([#75](https://github.com/folke/flash.nvim/issues/75)) ([40313ec](https://github.com/folke/flash.nvim/commit/40313ecf3140264b6e9d9611a3832a32e5ab7a46))
* **search:** fixup for search commmands ([0f2d53d](https://github.com/folke/flash.nvim/commit/0f2d53d63e9d90f7a310509fbf4e98fbe21be56e))

## [1.9.0](https://github.com/folke/flash.nvim/compare/v1.8.0...v1.9.0) (2023-06-26)


### Features

* **treesitter:** added treesitter search to label ts nodes around search matches ([6f791d4](https://github.com/folke/flash.nvim/commit/6f791d4709a2c8ef2373302d3a067ae45fdc2f8d))


### Bug Fixes

* added unicode support for labels/skips and fuzzy search. See [#66](https://github.com/folke/flash.nvim/issues/66) ([2528752](https://github.com/folke/flash.nvim/commit/2528752b7efbf3f67cce8b9d0d75ee769f72c01e))
* **state:** restore window views on esc or ctrl-c ([7b21dfd](https://github.com/folke/flash.nvim/commit/7b21dfddcf7ccc4fb665ca0db80810210f8cde7c))
* **treesitter:** add incremental = false to default settings of treesitter ([1cf706f](https://github.com/folke/flash.nvim/commit/1cf706f342bea4447c2f8ac13c2fab9df060ce1e))

## [1.8.0](https://github.com/folke/flash.nvim/compare/v1.7.0...v1.8.0) (2023-06-26)


### Features

* added prompt window that shows pattern during jump (can be disabled) ([3fff703](https://github.com/folke/flash.nvim/commit/3fff7033f53b8f0714efd0dd56b03aa3f22c6376))
* **api:** allow a match to disable getting a label ([ea56cea](https://github.com/folke/flash.nvim/commit/ea56ceaea4760b2031719d8e5eb1b6231ef9f43c))
* **api:** allow a match to enable/disable highlight ([38eca97](https://github.com/folke/flash.nvim/commit/38eca97c8bdbbbd7be64b562eeb9f964cf8bc145))
* **ffi:** added `mappings_enabled` ([6f6af15](https://github.com/folke/flash.nvim/commit/6f6af15b491bee14460873fe63fc7b20e7c73dd8))
* **hacks:** added support for detecting user input waiting ([81c610a](https://github.com/folke/flash.nvim/commit/81c610acd374b40fc7a7fa4b493b1b9783d3d52d))
* **highlight:** added option to disable distance based labeling ([ad9212f](https://github.com/folke/flash.nvim/commit/ad9212f28ef37e893a5a4113f8757052b2035c36))
* **highlight:** show fake cursor in all windows when flash is active ([471b165](https://github.com/folke/flash.nvim/commit/471b165722ae5db4ddad7cbaf1d351127fb55529))
* **highlight:** when running in vscode, set default hl groups to something that works ([d4c30b1](https://github.com/folke/flash.nvim/commit/d4c30b169f01b8108c5bc38e230a975408133603))
* **jump:** added jump offset ([0f2dfac](https://github.com/folke/flash.nvim/commit/0f2dfaca329ed9a7db9e5062d964492cf51765eb))
* **jump:** added options for remote operator pending mode ([436d1f4](https://github.com/folke/flash.nvim/commit/436d1f402a696733b8a1512072bbd0ac8da72cea))
* **jump:** remote operator pending operations will now always return to the original window ([c11d0d1](https://github.com/folke/flash.nvim/commit/c11d0d15660ce309c733982b2c34cd54c9c9d9f0))
* **label:** minimum pattern length to show labels. Closes [#68](https://github.com/folke/flash.nvim/issues/68) ([2c2302a](https://github.com/folke/flash.nvim/commit/2c2302a3eae1dc72d2140c58974e2f73df41556d))
* matcher function now has a from/to opts param ([1cb669d](https://github.com/folke/flash.nvim/commit/1cb669d2ce074ea39722da9fec6b0c2686b3b484))
* **remote_op:** allow setting motion to `nil` to automatically start a new motion when needed ([259062d](https://github.com/folke/flash.nvim/commit/259062ddc47f9de11e0e498cd58040705d7b6f5c))
* **remote:** implement remote using new `remote_op` options ([51f5c35](https://github.com/folke/flash.nvim/commit/51f5c352db8791f4218e19cc7fa40948cdda9647))
* searches can now be continued. Closes [#54](https://github.com/folke/flash.nvim/issues/54) ([487aa52](https://github.com/folke/flash.nvim/commit/487aa52956fdf79ba545151227b0ad39c5276c69))
* **state:** added support for restoring all window views and current window ([01736c0](https://github.com/folke/flash.nvim/commit/01736c01eb43dcf497a946689c7f434b1d13b4a8))
* **util:** luv check that does something when something finishes ([a3643eb](https://github.com/folke/flash.nvim/commit/a3643eb5424c12b5abc7b08a74d0d53fa5a29af0))
* **vscode:** make flash work properly in vscode by updating/changing the default config. Fixes [#58](https://github.com/folke/flash.nvim/issues/58) ([fa72836](https://github.com/folke/flash.nvim/commit/fa72836760417436cfe8e33ee74edaefd8ee9e00))


### Bug Fixes

* **config:** process modes in correct order. Fixes [#50](https://github.com/folke/flash.nvim/issues/50) again ([919cbe4](https://github.com/folke/flash.nvim/commit/919cbe49b66758cf57529847c396e718a9883de0))
* disable prompt on vscode ([f93b33d](https://github.com/folke/flash.nvim/commit/f93b33d736fb2eb6f28526ab465cfe7f32e7d96f))
* **jump:** fixup to always use a motion for remote ops ([11fa883](https://github.com/folke/flash.nvim/commit/11fa8833c62175a88fc35c50f1d23d5002d20fda))
* **jump:** improved operator pending mode for jumps ([16f785f](https://github.com/folke/flash.nvim/commit/16f785f26e74b8f0b49901356c57cda2a06379f5))
* **jump:** operator pending mode for remote jumps now behaves correctly ([cb24e66](https://github.com/folke/flash.nvim/commit/cb24e667ea58cfa7ea9df9fdf41bb6a26ea13da1))
* **remote:** make sure opts always exists ([7083750](https://github.com/folke/flash.nvim/commit/7083750697dea16b3943ca8a92c958acd83c2126))
* **search:** added support for search-commands. Fixes [#67](https://github.com/folke/flash.nvim/issues/67) ([7a59c42](https://github.com/folke/flash.nvim/commit/7a59c4239ed11ca3ec91cd7544535d836f09eb20))

## [1.7.0](https://github.com/folke/flash.nvim/compare/v1.6.0...v1.7.0) (2023-06-24)


### Features

* **config:** allow mode inheritance. Closes [#50](https://github.com/folke/flash.nvim/issues/50) ([3deefe8](https://github.com/folke/flash.nvim/commit/3deefe88e02e68c163c320614be1727fa887cd65))
* **jump:** added option to force inclusive/exclusive. Closes [#49](https://github.com/folke/flash.nvim/issues/49) ([e71efbf](https://github.com/folke/flash.nvim/commit/e71efbfbc73df21d3e79d30c4c27bd29892c216c))
* **remote:** peoperly deal with c for remote. Will jump back when leaving insert mode ([1075013](https://github.com/folke/flash.nvim/commit/10750139d3d4f2fb6c7bb8cc33aef988a7b26b7c))
* **state:** allow passing a callable object as matcher ([f49fa9c](https://github.com/folke/flash.nvim/commit/f49fa9cbddd6a30c59420892e09f57f391bd9516))


### Bug Fixes

* **cache:** allow current window to be excluded ([770763c](https://github.com/folke/flash.nvim/commit/770763ce2d2b4c340249cb7000de81c2085438c8))
* **cache:** fixup for window selection ([ed3bec6](https://github.com/folke/flash.nvim/commit/ed3bec6da9b92cee4954bfb71c4e71d06406191c))
* **char:** add group to autocmd ([fc08d27](https://github.com/folke/flash.nvim/commit/fc08d279ddb92ba2323684a2077aa7797384fc3c))
* **remote:** properly restore remote window as well. Also remove the `normal! o` ([587a243](https://github.com/folke/flash.nvim/commit/587a2436f84301b84937242657dcc03be4a80702))


### Performance Improvements

* **remote:** restore views on TextYankPost ([d4dadc8](https://github.com/folke/flash.nvim/commit/d4dadc8fae53ded2a51a2ca0a9d82889e148e0b7))

## [1.6.0](https://github.com/folke/flash.nvim/compare/v1.5.0...v1.6.0) (2023-06-24)


### Features

* **config:** pattern can now have a `max_length`. When length is reached, labels are no longer skipped. When it exceeds, either a jump is followed or the search is ended ([bd9dbee](https://github.com/folke/flash.nvim/commit/bd9dbee041296a582faa6dfe25e1af87d65614c7))


### Bug Fixes

* **config:** exclude noice by default ([bc9a599](https://github.com/folke/flash.nvim/commit/bc9a5992b947ae84b5c1458f0b117abda1b61154))
* **repeat:** make sure repeat is enabled for char searches. Fixes [#40](https://github.com/folke/flash.nvim/issues/40) ([219f0c0](https://github.com/folke/flash.nvim/commit/219f0c09b664257a7d9b46023bcb24563ae49832))
* **state:** always reposition the cursor on incremental mode ([81e38d6](https://github.com/folke/flash.nvim/commit/81e38d604d285d835a9186f82e28a302bc048128))

## [1.5.0](https://github.com/folke/flash.nvim/compare/v1.4.1...v1.5.0) (2023-06-23)


### Features

* added remote plugin ([fb50450](https://github.com/folke/flash.nvim/commit/fb5045044f28caf08ca6d89e9fe40874138faeef))
* flash remote. thank you [@max397574](https://github.com/max397574)! ([809ea4f](https://github.com/folke/flash.nvim/commit/809ea4f804d831ca5ff26c94b8d409ad9dfec8eb))


### Bug Fixes

* **char:** always stop highlights in insert mode ([64e5129](https://github.com/folke/flash.nvim/commit/64e51292e83e7ce409248fd07ff00b51a993a6c0))

## [1.4.1](https://github.com/folke/flash.nvim/compare/v1.4.0...v1.4.1) (2023-06-23)


### Bug Fixes

* **char:** don't repeat on motion char when executing a macro. See [#34](https://github.com/folke/flash.nvim/issues/34) ([674cfb4](https://github.com/folke/flash.nvim/commit/674cfb43e5424a5405661ba632810bacfc0a9c37))

## [1.4.0](https://github.com/folke/flash.nvim/compare/v1.3.0...v1.4.0) (2023-06-23)


### Features

* **char:** tfTF now behave like clever-f when repeating the motion. Fixes [#26](https://github.com/folke/flash.nvim/issues/26) ([97c3a99](https://github.com/folke/flash.nvim/commit/97c3a993e60ebdd42c7671af07620f705ee6378f))
* **config:** allow custom window filters. Added non-focusable windows by default ([e6ee00d](https://github.com/folke/flash.nvim/commit/e6ee00d4e76edac8cbcabe0f442a5ec34450d1f6))


### Bug Fixes

* **config:** dont show flash in cmp_menu ([29c35de](https://github.com/folke/flash.nvim/commit/29c35dec5f81504ee63a39fec90597222620af0a))
* **treesitter:** always disable incremental mode for treesitter. Fixes [#27](https://github.com/folke/flash.nvim/issues/27) ([6e84716](https://github.com/folke/flash.nvim/commit/6e8471673a7158a8820986f6aad770a912a66eed))

## [1.3.0](https://github.com/folke/flash.nvim/compare/v1.2.0...v1.3.0) (2023-06-22)


### Features

* **char:** optionally disable some ftFT keymaps ([3e27d9a](https://github.com/folke/flash.nvim/commit/3e27d9ab07b9363b0ecb94645eae38909f7baa5a))
* **config:** show labels for current jump target by default ([0dcc00e](https://github.com/folke/flash.nvim/commit/0dcc00ea6a3b312b8e081f3f582adc26a4721ac7))
* **search:** optional trigger character. Not recommended. Fixes [#21](https://github.com/folke/flash.nvim/issues/21) ([cb0977c](https://github.com/folke/flash.nvim/commit/cb0977cd0f7cec4573ee1210edc2032739866b2b))


### Bug Fixes

* **char:** fixup for keys ([81469aa](https://github.com/folke/flash.nvim/commit/81469aaf3ccf15d7c942bbd9144f2c06f68fe1ee))
* **treesitter:** properly deal with nodes ending at col 0. Fixes [#17](https://github.com/folke/flash.nvim/issues/17) ([6cd4414](https://github.com/folke/flash.nvim/commit/6cd44145f75392fbfe67700b59517dbf8324bd21))
* **treesitter:** removed debug print ([0fabd1b](https://github.com/folke/flash.nvim/commit/0fabd1b4ddea5754576ccc09a515867a3ac129ce))

## [1.2.0](https://github.com/folke/flash.nvim/compare/v1.1.0...v1.2.0) (2023-06-21)


### Features

* added example that matches beginning of words only ([1e2c61d](https://github.com/folke/flash.nvim/commit/1e2c61d8db882cc001fcebff9eba2549336ce87a))
* **config:** setting to disable uppercase labels. Fixes [#11](https://github.com/folke/flash.nvim/issues/11) ([13d7b3e](https://github.com/folke/flash.nvim/commit/13d7b3e70cadc7e4d64f818a04fbca2b33ac1d4f))
* **labeler:** reuse only lowercase labels by default. See [#11](https://github.com/folke/flash.nvim/issues/11) ([8f0b9ed](https://github.com/folke/flash.nvim/commit/8f0b9ed656d7b92eb0d60c34b6a5bd3803cc0e0b))

## [1.1.0](https://github.com/folke/flash.nvim/compare/v1.0.0...v1.1.0) (2023-06-21)


### Features

* added config.jump.autojump. Fixes [#5](https://github.com/folke/flash.nvim/issues/5) ([1808d3e](https://github.com/folke/flash.nvim/commit/1808d3ebb6ea5810957b8f8e32aab8f4e9e7f14c))
* added custom actions on label select ([eb0769f](https://github.com/folke/flash.nvim/commit/eb0769ff38001ed3eead9e54289b7f63387e1525))
* added example plugin that shows a diagnostic at a certain label without moving the cursor ([7a9bd11](https://github.com/folke/flash.nvim/commit/7a9bd118a3b4d2829d4718c26d8af21b36ebfb87))


### Bug Fixes

* **config:** get mode opts from options instead of defaults. Fixes [#4](https://github.com/folke/flash.nvim/issues/4) ([41fab4c](https://github.com/folke/flash.nvim/commit/41fab4cb225d9233fec7987bb1445c9768d84caf))
* **diag:** always hide when done ([226c634](https://github.com/folke/flash.nvim/commit/226c634e3db6f02eb734d37c16d729bae41a77ef))
* **jump:** register and history should use pattern.search instead of pattern. Fixes [#7](https://github.com/folke/flash.nvim/issues/7) ([a11cf6a](https://github.com/folke/flash.nvim/commit/a11cf6ad205dd2493d2af6643bc20bef925004f5))
* **treesitter:** make treesitter plugin work with custom labels. Fixes [#9](https://github.com/folke/flash.nvim/issues/9) ([3fac625](https://github.com/folke/flash.nvim/commit/3fac6253fd59e7c32300e6209c8f1e60ea8a3c81))

## 1.0.0 (2023-06-21)


### Features

* abort_pattern can now be false ([e036667](https://github.com/folke/flash.nvim/commit/e0366678e337df4a93c0704e77a6909e617950c3))
* add option to save loc to jumplist before jump ([0aae816](https://github.com/folke/flash.nvim/commit/0aae816ef419ad4554a784a07fe239aeee9a6934))
* added char searches, f, F, t, T ([06839d8](https://github.com/folke/flash.nvim/commit/06839d8ac7f2ca42b639fc8f90e2c655234bba9a))
* added config for forward/wrap ([b9649bd](https://github.com/folke/flash.nvim/commit/b9649bd226da89bcbef7fb6b27e5d3a08d0fe6b4))
* added config.search.regex ([bda1be0](https://github.com/folke/flash.nvim/commit/bda1be00bca62d7ebd9de4c7848e7c70a65f2f91))
* added ffi based searcher. Finally 100% correct end pos for matches ([46b41d1](https://github.com/folke/flash.nvim/commit/46b41d13d6943443c20b3bf87fdf8eb495fee4c2))
* added option to label the first match ([63b75ed](https://github.com/folke/flash.nvim/commit/63b75ed8dcaec7efaf6e67e3913b59f2e614f043))
* added optional backdrop ([2172a90](https://github.com/folke/flash.nvim/commit/2172a907aeba4a3961e399044a2f4ca1087e044d))
* added support for label offsets and label styles ([3e9f630](https://github.com/folke/flash.nvim/commit/3e9f630ce04bdda14669592bc5d36af594077e95))
* added treesitter command ([fd9bd80](https://github.com/folke/flash.nvim/commit/fd9bd8015a7df2b8aedc294bc517264837d218f9))
* advance for results ([9d70126](https://github.com/folke/flash.nvim/commit/9d70126e09b20125752a43c1e26041eecc4f721c))
* allow to always render search highlight to prevent flickering when updating ui ([ff0e25f](https://github.com/folke/flash.nvim/commit/ff0e25f63ae98f7ab2735293a40f02e8cfc85d2a))
* **charsearch:** close on &lt;esc&gt; ([ee3228a](https://github.com/folke/flash.nvim/commit/ee3228af6b82204cb03c317526a0212229953272))
* **charsearch:** make char search dot repeatable ([91485c1](https://github.com/folke/flash.nvim/commit/91485c12b2685bdde097b2351725e973cc2e1274))
* dont stabalize labels for treesitter ([b20ad86](https://github.com/folke/flash.nvim/commit/b20ad8652f34a477f6bdab912258b176aeebdd0d))
* expose commands on main module ([70130d2](https://github.com/folke/flash.nvim/commit/70130d29a3c4c8d90d96caae5871d0cc19e3f283))
* fuzzy matching ([7407dd6](https://github.com/folke/flash.nvim/commit/7407dd679c90986dff09b22a690feb52aa5ea31a))
* highlight groups config ([313e252](https://github.com/folke/flash.nvim/commit/313e252ecfd3252d2e39d7c012b0674388d65f8d))
* **highlight:** added support for before/after labels ([d0133d2](https://github.com/folke/flash.nvim/commit/d0133d2966695f063f8909a0d80a97cd90d2848c))
* **highlight:** allow diffrerent namespaces for highlight ([2649b18](https://github.com/folke/flash.nvim/commit/2649b1888fd84d1cee0ab3d5fdc5e82c8a5f391c))
* initial version ([22913c6](https://github.com/folke/flash.nvim/commit/22913c65a1c960e3449c813824351abbdb327c7b))
* jump position (start, end or range) ([335a5a9](https://github.com/folke/flash.nvim/commit/335a5a91222680f92c585c16d94d183a57b13c8d))
* labels are now skipped based on regex searches to be able to fully support regex patterns ([e704d88](https://github.com/folke/flash.nvim/commit/e704d8846fd2d8189f127f2b080812ed2518fdc4))
* lazy require ([171b9ff](https://github.com/folke/flash.nvim/commit/171b9ff3034b2afb5ad9a0420a906a8c597037ba))
* make all the things repeatable without needing `expr=true` ([ec3a8ac](https://github.com/folke/flash.nvim/commit/ec3a8ac3ebfc9957c65620bcae7d91ed38a334b2))
* much improved repeat api ([2f76471](https://github.com/folke/flash.nvim/commit/2f76471f3a178234a3b08a6ae5ca9f8082bacc46))
* multiple modes ([ed1150f](https://github.com/folke/flash.nvim/commit/ed1150f2cabcca526894423de8fda74d756a0cff))
* **pattern:** custom pattern functions ([b9e13f2](https://github.com/folke/flash.nvim/commit/b9e13f2c8cf603e70d7eff410ffbd88c8611d6d0))
* **repeat:** show warning when keymap expr didn't execute. probably because expr=true was not used ([789d3b2](https://github.com/folke/flash.nvim/commit/789d3b22610fe8f45f7451afac5b1921db852dd6))
* stable labels ([3e6b345](https://github.com/folke/flash.nvim/commit/3e6b345f590c70c83ccbe720afc268ba9ba3b442))
* **state:** proper support for incremental search ([8a0fa11](https://github.com/folke/flash.nvim/commit/8a0fa1147cfad21b6576ee4d9320de6e78b1c24c))
* **state:** state will now automatically updated on changedtick or when buf changes ([60193cb](https://github.com/folke/flash.nvim/commit/60193cb3aa384938bd7b9be8d5b594c0ebe0c867))
* **state:** update matcher when view changed ([9f4dc50](https://github.com/folke/flash.nvim/commit/9f4dc506987a9381d67e3e602e9950a622c76276))
* treesitter node jumping ([119643f](https://github.com/folke/flash.nvim/commit/119643fd672a959233da3b1c3b61de965dfe765b))
* **treesitter:** ; & , to expand/descrease selection ([6551d97](https://github.com/folke/flash.nvim/commit/6551d970d270bda2b6bf9be09944196d8782a329))
* **treesitter:** allow custom options ([d9d5e75](https://github.com/folke/flash.nvim/commit/d9d5e7558e11e1cdb9a48c87e442444664b3c0cf))
* util module for dot-repeat ([e6f02b1](https://github.com/folke/flash.nvim/commit/e6f02b15608b625266f1564b8005c36d56f7fa71))


### Bug Fixes

* allow space in string ([f1b8691](https://github.com/folke/flash.nvim/commit/f1b86913daa85aef94fae07e03cab8ccf7f9137f))
* calculate target in update ([f3f915a](https://github.com/folke/flash.nvim/commit/f3f915ac0b5c4ff4598dd73b65cff9f9c0d3e57b))
* **charsearch:** inclusive/exclusive operator pending fix ([fb1867c](https://github.com/folke/flash.nvim/commit/fb1867c908e488a7dbe1a83f7cad57a826bf977f))
* **charsearch:** mode ([b8c18ba](https://github.com/folke/flash.nvim/commit/b8c18baad82145fe097db4d13440d44a9005f30d))
* **config:** register and nohlsearch are disables by default ([f20d2f8](https://github.com/folke/flash.nvim/commit/f20d2f8d34142ec1674284f582e57f6f66a99cd8))
* dont set search register by default ([f7352f7](https://github.com/folke/flash.nvim/commit/f7352f7c7e90e3e0b5818b398d543e2146f045ad))
* fixup for first -&gt; current ([43b96c6](https://github.com/folke/flash.nvim/commit/43b96c69d7f7fd97f5c9ec316cf8ee3c30badc48))
* **highlight:** highlight each line of the backdrop separately to fix extmark priorities ([08bf4f6](https://github.com/folke/flash.nvim/commit/08bf4f6fad136743c6791f6db4659f314fe69104))
* **highlight:** proper nvim 0.10.0 check for inline extmarks ([6da8904](https://github.com/folke/flash.nvim/commit/6da8904ed698069395baab49b168b37b0a35b839))
* **highlight:** set cursorline hl group ([8715685](https://github.com/folke/flash.nvim/commit/8715685cd24e5d5727442063ce7e347bb0b567b7))
* **init:** pass opts to config ([0627e2f](https://github.com/folke/flash.nvim/commit/0627e2f09e9a7b26d8755d8e4994e38cfdd58ba5))
* **jump:** check pattern for jump target ([d29d5fc](https://github.com/folke/flash.nvim/commit/d29d5fc41dcbe6e7c751c30d28b362400f45f870))
* **jump:** dont change ordering of matches when calculating labels ([8611eab](https://github.com/folke/flash.nvim/commit/8611eaba93c080175026dbd41fac9a7a9e535637))
* **jump:** fix inclusive/excusive for operator pending mode ([99c99a7](https://github.com/folke/flash.nvim/commit/99c99a75754f107eef0cbc23f4745e7c0d784848))
* **jump:** make it all work in operator pending mode ([1005faa](https://github.com/folke/flash.nvim/commit/1005faa1c21dcaa37232fd93c2ef7c71fc3b3099))
* **labeler:** dont include end_pos to re-use stable labels ([dadca0e](https://github.com/folke/flash.nvim/commit/dadca0e75335dd9e3083ea11cd41f1d197ebe1a7))
* **labels:** fixed some edge cases regarding labels ([124d1b6](https://github.com/folke/flash.nvim/commit/124d1b6900b30f5a2e1c60bc6a4ac0e1a0de889a))
* **matcher:** match end_pos when finding relative to another match ([0794ba2](https://github.com/folke/flash.nvim/commit/0794ba238ada4ab820940a63dbd54f29679d10be))
* **matcher:** ordering ([e46a629](https://github.com/folke/flash.nvim/commit/e46a629c679a022e822a4243ad15ebcb1474412d))
* **search:** added support for match ([e3e3958](https://github.com/folke/flash.nvim/commit/e3e3958c871bf46d808605afbdcf07cafb1e98e4))
* **search:** cleanup and add search to history ([175ffd9](https://github.com/folke/flash.nvim/commit/175ffd9960fdaf65b00d00782fdc0505678e9162))
* **search:** dont add labels if too many results ([959af4e](https://github.com/folke/flash.nvim/commit/959af4e095df35a62200a35b1f3aef2e652c8dd5))
* **searcher:** don't use ignore case for labels and skip both upper/lower when needed ([1b48511](https://github.com/folke/flash.nvim/commit/1b48511efa0834deb07461b3e076c8bafb66d876))
* **searcher:** finally was able to properly fix finding ends of matches ([4251741](https://github.com/folke/flash.nvim/commit/4251741114187823b94957dfad40e7dcfa82ac2d))
* **searcher:** skip all labels when pattern ends with escape character ([530038d](https://github.com/folke/flash.nvim/commit/530038d05925373feddb4742dcf742401532ed69))
* **searcher:** use vim.regex to get match end and added support for multi-line ([ffcdf20](https://github.com/folke/flash.nvim/commit/ffcdf20d7ff15117a984244e1258794fef10efe8))
* **search:** properly deal with invalid patterns ([46d6655](https://github.com/folke/flash.nvim/commit/46d6655891238b569ffa8c0334f2bdae39adc21e))
* **search:** skip all labels when pattern is invalid regex ([9bb8079](https://github.com/folke/flash.nvim/commit/9bb8079c82dccccc54ec107e243f845e996a492b))
* **state:** better operator pending mode detection for search ([f53dd07](https://github.com/folke/flash.nvim/commit/f53dd076af1e2f6f9374f6c26c8f474c83c5815d))
* **state:** force update when making visible ([ada913d](https://github.com/folke/flash.nvim/commit/ada913d2a1cbdb765493419202a48addaf2c873a))
* **state:** keep states as a key in a table to prevent double work ([4a6ea98](https://github.com/folke/flash.nvim/commit/4a6ea985c88eb8503515131f422d4cb856db4b3b))
* **state:** results sorting ([9da4d28](https://github.com/folke/flash.nvim/commit/9da4d285d0d453fc9eb0f3bfcebde68be334f066))
* **state:** stop searching when max matches reached ([4245e49](https://github.com/folke/flash.nvim/commit/4245e49fb878459bb5a074c9c8023900baf321cd))
* **treesitter:** use state.pos as cursor to get nodes ([d1185ad](https://github.com/folke/flash.nvim/commit/d1185add4a6f624b150896ba4eb32855ef9e35b7))


### Performance Improvements

* cache window matches ([678532a](https://github.com/folke/flash.nvim/commit/678532a956562a53887a5dda2e4513c3ba216de9))
* lazy require/setup ([2bbf721](https://github.com/folke/flash.nvim/commit/2bbf72189c875509ac37130f56fc4cb6e0f65139))
