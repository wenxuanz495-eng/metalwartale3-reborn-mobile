# 手游移植 README（现状评估与移植资料索引）· 20260920

> 定位：回答四个问题——**手游仓现在还剩什么、和端游差多少、什么不能动、怎么移植**。
> 所有数字为 2026-09-20 实测（双仓本地对比）。结论先行：**端游成果整体直接同步到手游不可行**
> （95 类文件双方都改过、server/资源全分叉），正确路径是"**触控基线不动 + server/资源整体换新 + 特性逐项回移**"。

## 一、手游仓家底（现状快照）

- 分支 `mobile/android-air`，工作区干净，**无远端（纯本地仓）**，HEAD `b9fdc8b`；
- 版本 **3.0.3**（`mobile\air-android\application.xml`，自本版起与端游版本号同步）；分叉基线 = 端游 `7e28a5e`（2026-08-07，端游 2.2.4 时代），
  其后 4 个手游自有提交：`71fae81`（适配层保全）、`a5be734`（瘦身，当日撤回）、`c11fa01`（revert）、`1332443`/`b9fdc8b`（README 与工具链路径）；
- **独立完整仓**：decompiled / swf / server / launcher / 构建链全套在仓，可独立构建可玩；
- **触控基础系统（基线，禁改）**，对应手游独有补丁类：
  - 虚拟摇杆与触控：`GamingUI.as`（15 处触控实现）、`KeysGroup.as`、`OneSkill.as`；
  - 移动 UI 缩放：`Dialogbox.as`、`Dialogbox2.as`、`GrowGiftUI/LeveLGiftUI/PayGiftUI`、`MustTopDialogBox.as`、`OneExchangeUI.as`；
  - AIR 存档：`LocalSave.as`（`superalloy_mobile_save` 独立存储）+ `sasave-ane\` 完整工程（as3/java/build-ane.ps1/extension.xml）；
  - 启动与打包：`build-apk.ps1`（armv7/armv8/x86/x64，captive runtime）、`test-release.p12`、`bootstrap\`、`dist\`、`stage\`、`Copyright.as`、`PayController.as`、`NewHeroCarAAHD.as`；
- 补丁清单 **115 项**（独立于端游 127 项，见 `config\build\swf-script-patches.txt`）。

## 二、与端游的差距（实测数字）

| 维度 | 差距 |
|---|---|
| 提交 | 端游自分叉以来 **290 提交**（`7e28a5e..HEAD`），覆盖 3.0 全部内容 |
| 客户端源码 | `decompiled` **193 个文件内容不同** + 端游独有 7 处（整目录 `mgcv1140`/`sever1130`/`sub1130` 反编译源、`scripts\mobile\`、`AirGravitySkill.as`、`etjv1130-assets\images`、一个 .bak 残留）；手游独有文件 0（适配都在双方同名文件里） |
| 补丁清单 | 端游独有 **29 类**（武器大复原的弹体/攻击/AI 类、`ChipCubeUI` 芯片修复、`VipUI`/`VipData` VIP 冷却、`HonorUI`/`HonorData` 称号隐藏、各图标类）；手游独有 **17 类**（即上面的触控基线）；**双改交集 95 类**——端游改过、手游也改过的手工合并面，含 `GamingUI`/`KeysGroup`/`OneSkill`/`SoundGroup`/`ServerUI`/`EventGroup`/`GoodsDefineGroup` 等要害 |
| 资源 SWF | `arms1100` / `bullet` / `sub1130` / `scene_city` 四件内容已分叉（端游侧携带老武器大复原主15+副17、黄金深渊五级、雪花2026、星际雷神重做、火神炮备弹的全部资源成果）；端游另新增 `sub25.swf` |
| server | **全部文件内容级差异**（BGM 歌单引擎 force/shutdown、编辑器、战车词条 `car_affix`、`go.mod` 等）；手游侧 server 无自有适配，可整目录换新 |
| scripts / launcher | 23 / 2 个文件不同（端游 0919 去硬编码改造等） |
| 周边入口 | 手游还保留旧制：`打开公告.bat` 旧名单文件版、公告旧双文件名（`公告.txt`/`游戏公告.txt`）、静音版 BAT、`build.bat`/`修改器.bat` 等端游已归档入口 |

## 三、基线红线（不可动）

1. **触控基础系统 = 基线**。手游独有 17 类即触控/存档/缩放/打包适配层，以手游版为准；
   端游同名文件的任何改动**只能三方对照后手工并入**，禁止整文件覆盖。
2. **双改交集 95 类是合并要害**：`GamingUI`、`KeysGroup`、`OneSkill`（触控×端游改动）与
   `SoundGroup`（BGM 修复）、`ServerUI`（公告体系）、`EventGroup`（VIP 冷却调用点）、`GoodsDefineGroup`（黄金黑绳门控）等——
   移植前先做三方对照：分叉基线 `7e28a5e` vs 手游版 vs 端游版，弄清双方各改了什么再动手。
3. 工程红线两仓同遵：FFDec 控制流回归审批、改动 + 补丁清单两步走、构建回读验证、构建自检双 0。

## 四、移植分层路线（建议顺序）

- **L1 直接换新（无手游适配，低风险先行）**：
  `server\` 整目录换端游版（随后跑手游构建验证）、新增 `sub25.swf`、构建链去硬编码改造移植、公告体系对齐（文件更名 + 职责分离，`ServerUI.as` 按手游版手工并入）；
- **L2 资源回迁（资源不带逻辑，整件收）**：
  `arms1100` / `bullet` / `sub1130` / `scene_city` 取端游当前版重建产物——武器大复原全部资源成果随件而来；
  用端游同款 manifest 哈希清单校验；手游构建自检（资源校验项数可能与端游 175 不同，按手游清单为准）；
- **L3 特性逐项回移（长线，每项独立验证）**：
  BGM 歌单引擎与场景切换两轮修复、芯片合成复制修复（`ChipCubeUI`）、称号隐藏（`HighPlayerBox`/`HonorUI`/`HonorData`）、
  VIP 副本冷却（`VipData`/`VipUI`/`EventGroup`）、黄金黑绳禁直接研发（`GoodsDefineGroup`/`ArmsResearchUI`）、
  火神炮备弹、雪花2026、星际雷神重做、黄金深渊五级与黄金恶魔牙+4、开发者歌单分配修复……
  每项流程：三方对照 → 改手游 `decompiled` → 登记手游补丁清单 → `构建.bat` → FFDec 回读 → 双自检 → 实机；
- 每完成一批 → `application.xml` 版本号 +1，`build-apk.ps1` 实包验证，产物归 `临时封装目录\手游端\1.x.x\<版本>\`。

## 五、现在方便整体移植吗？——不方便，但可以分层启动

把端游 `decompiled`/`swf`/`server` 直接盖到手游仓 = 触控基线被覆盖（95 类双改全丢），**不可行**。
但 L1（server/资源外围）与 L2（四件资源 SWF）不含触控冲突，可先行；
L3 按特性排队，每项独立可验证，不阻塞其他项。
**启动任何移植动作前**：先用 `build-apk.ps1` 打一个 1.2.4 基线 APK 留底（归 `临时封装目录\手游端\1.x.x\`），确保随时可回退。

## 六、资料索引

- **性能与目录优化方案：本目录《docs\优化方案-20260920.md》**（掉帧七项根因锚点 + P0~P3 优化分层 + 目录整理提案，20260920）；
- 端游特性与修复文档主区：`..\metalwartale3-reborn.git\更新总结\`（按版本/家族/bug 维护；移植某特性前先读对应总结）；
- 端游机制速查：`..\metalwartale3-reborn.git\更新总结\武器家族内容\通用\原版武器相关资料总结\原版武器文件资料地图与调查路径-20260920.md`；
- 手游工作档案（保全/瘦身撤回史）：本仓 `README.md` 第五节；
- `docs\` 下为重组前旧扁平结构文档，部分过时，仅作历史参考；现行规则以端游仓 `docs\` 为准。
## 七、移植工程化：让整体移植变省力的仓库整理方案（20260920 提案，待批准执行）

核心思路：**两仓同源**——手游仓的 git 历史是端游仓历史的前缀（分叉于 `7e28a5e`），这个天然优势目前完全没用上。
把端游仓挂成手游仓的第二远端后，端游每一个提交都可以在手游侧 **cherry-pick**：git 三方合并自动处理非冲突部分，
冲突精确暴露在 95 类双改文件上；资源文件可以按版本号从 git 直接取件。
移植从"人肉对照抄代码"变成"git 辅助的逐提交回放 + 台账销项"。

1. **挂远端 + 打基准 tag**（一次性，零风险）：`git remote add desktop ..\metalwartale3-reborn.git` → `git fetch desktop`；
   `git tag fork-base 7e28a5e`——分叉基准固定下来，此后任何文件都能一键三方对照（基线 vs 手游 vs 端游）。
2. **移植分支**：开 `port/desktop-sync` 承载全部移植改动，`mobile/android-air` 保持稳定发行线；每完成一个里程碑合回。
3. **移植台账**：新增《移植台账.md》按特性组列队——server 换新 / 四件资源 SWF / sub25 / 公告体系 / BGM 引擎与两轮修复 /
   芯片合成修复 / 称号隐藏 / VIP 冷却 / 黄金黑绳门控 / 火神炮备弹 / 雪花2026 / 星际雷神重做 / 黄金深渊五级 / 特效预烘焙规范……
   每项登记：状态、涉及类、端游源提交哈希（cherry-pick `-x` 自动留痕）、冲突与适配决策、实机验证。
   95 类双改从"一团乱麻"变成可视队列，移植进度随时可盘点。
4. **外围先对齐（收缩无谓 diff）**：L1 的 server 换新、scripts 对齐、公告体系、根目录 BAT 整理先行——
   结构噪声越小，后续 cherry-pick 冲突越纯净，特性移植越省心。这就是"整理仓库方便整体移植"的主体。
5. **资源按版本号取件**：`git checkout desktop/main -- swf/arms1100.swf` 等直接取（同源历史，二进制 blob 复用，
   来源与回滚都有 git 兜底），配 manifest 哈希校验。
6. **可复跑差异报表**：`TMP\` 放一个小脚本，按需重出本评估同款的"双仓三方对照表"，移植过程中随时看剩余差距收敛。
7. **备份兜底**：手游仓无远端，移植开工前先补备份（F 盘冷备或 GitHub 私有仓，二选一待裁定）；
   1.2.4 基线 APK 留底同步做（归 `临时封装目录\手游端\1.x.x\`）。

> 执行成本评估：1/2/7 是纯 git 操作，分钟级；3 台账骨架由现有评估直接生成；4 即已批准后执行的目录整理提案 + L1。
> 全部就绪后，L3 每一项的作业形态固定为：**cherry-pick → 只解双改文件冲突 → 手游补丁清单登记 → 构建 → 回读 → 双自检 → 实机 → 台账销项**。

