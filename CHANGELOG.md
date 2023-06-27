# Changelog

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
