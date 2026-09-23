# 超合金战记 · 手游版（metalwartale3-reborn-mobile）

> 本仓库是《超合金战记》**手游版**（AIR/Android）的**独立完整仓库**：
> 游戏本体（decompiled 源码 / SWF 资源 / server / launcher）与移动特有层（触屏适配、ANE、打包）都在本仓。
> 端游仓库：`D:\superalloy\metalwartale3-reborn.git`（工程文档与端游侧更新总结的主文档区在那边）。
>
> **当前版本 3.0.4**——bug 修复版（版本名延续上一版、只顺延版本号）；自 3.0.3 起版本号与端游同步。
> 本版修复：关卡星级显示、帝皇战车兑换、金币空间结算与金币手动拾取、VIP 折扣价格显示。
> 3.0 大版本内容（老武器家族特效大复原、黄金系列新形态、星际雷神重做、雪花炮 2026、火神炮实弹化、
> 触屏链式跳跃等）见包内《游戏更新公告.txt》与 `更新总结\`。

## 一、版本与两仓关系

| 项 | 值 |
|---|---|
| 手游版本号 | **3.0.4**（bug 修复版）；自 3.0.3 起与端游版本号同步（2026-09-20 裁定；此前 1.0~1.2.5 独立计数） |
| 分叉基线 | 端游 **2.2.4 时代**（提交 `7e28a5e`，2026-08-07）；本仓 git 历史为端游历史的前缀 |
| 演进策略 | 端游功能按批 cherry-pick 回移，**冲突时触屏基础 17 类以手游版为准**；进度唯一账本 = [移植台账.md](移植台账.md)（对齐 3.0.3 的批 1~6 已全部关闭） |
| 存档 | 与端游存档互通为既定方向（待实现验证）；本机存档走 `superalloy_mobile_save` 独立存储 |

## 二、运行架构

```text
真机 AIR（captive runtime）＋ sasave-ane（存档分享/来电动细）
   │  MobileBootstrap loadBytes 引导
   ▼
game.swf（FFDec 清单驱动最小补丁构建，148 项；触屏适配层 + 原版内置音乐）
```

- 手游**无本地 server**：端游的外置 BGM/公告服务端架构不适用于手机，音乐保持原版内置，公告以 `notice_update.txt`/`notice_thanks.txt` 随包内置。
- 触屏基础系统 17 类（虚拟摇杆、触屏基线）为**移植红线基线**，任何端游回移不得覆盖，见 [移植README.md](移植README.md)。

## 三、快速开始

| 身份 | 入口 |
|---|---|
| 玩家 | 安装 `D:\superalloy\临时封装目录\手游端\3.x.x\` 最新 APK（目录内自动只保留最新一个，附 `.sha256.txt` 校验件） |
| 开发构建 | [`构建.bat`](构建.bat)（= `scripts\build_all.bat`，产物 `build\game.swf`）→ FFDec 回读 → `scripts\launch_game.bat --check sa` / `--check sa_debug` 双自检 |
| 本地试玩 | `启动游戏-flashplayer_sa.bat` / `_debug.bat` |
| 打 APK | `$env:AIR_SDK="D:\superalloy\工具\air-mobile-tools\airsdk-50.2.4.1"` 后运行 `mobile\air-android\build-apk.ps1`（`-Arch armv7/armv8/x86/x64`、`-Release`、`-Theme` 主题；captive runtime） |
| 重编 ANE | `mobile\air-android\sasave-ane\build-ane.ps1` |
| 装机 | `adb install -r <apk>`（vivo 必须先亮屏解锁，否则授权弹窗静默拒绝）；排错看 `build\saves\client_errors.log` 与 logcat 末条业务 trace |

APK 产物自动归档到 `D:\superalloy\临时封装目录\手游端\3.x.x\`（命名 `SuperAlloy-Mobile-<版本>-[-主题]-YYYYMMDD-<arch>.apk` 附 `.sha256.txt`，自动清旧仅留最新；封装先落仓内 ASCII 目录 `dist\` 再搬入，规避 adt 中文路径代码页坑）。签名证书 `test-release.p12`（首跑自动生成，密码 `superalloy-test`，勿入库）。

## 四、目录导航

```text
metalwartale3-reborn-mobile\
├── mobile\air-android\        手游特有层：application.xml(版本号)、bootstrap\、sasave-ane\、build-apk.ps1、stage\、dist\
├── decompiled\                游戏逻辑源码（含触屏适配层与手游专项改动）
├── swf\                       分包 SWF 源资源与构建基线
├── server\ / launcher\        本地 Go 服务与启动器源码（与端游同源）
├── config\ scripts\           构建清单（148 项补丁 + 二进制补丁 + 资源清单）与构建/自检/装包脚本
├── docs\                      工程文档（BAT_RUNTIME / PROJECT_STATUS / SEAL_RULES / 弹速提示 / 优化方案等）
├── 更新总结\                   bug 维护与已完成专项归档（含 README 索引）
├── archive\ tools\ assets\    旧构建脚本归档、本地工具链、装包 UI 素材
├── runtime\ build\            PC 试玩运行时与构建产物（本地生成）
└── 根目录 BAT/EXE             玩家入口：启动、修改器、存档维护、公告、BGM 曲库（勿移动改名）
```

## 五、文档导航（按序阅读）

1. [AGENTS.md](AGENTS.md) — 协作红线（AI 必读，2026-09-20 重写）
2. [移植台账.md](移植台账.md) — 端游→手游移植唯一进度账本（L1/L2/L3/F 系列 + 对齐 3.0.3 批 1~6 全部关闭）
3. [移植README.md](移植README.md) — 移植作业规范（基线留底 / 三方对照 / 触屏 17 类红线）
4. [docs\README.md](docs/README.md) 与 [docs\BAT_RUNTIME.md](docs/BAT_RUNTIME.md) — 工程文档索引与运行自检
5. [更新总结\README.md](更新总结/README.md) — bug 维护与专项归档索引；[更新总结\版本标签\README.md](更新总结/版本标签/README.md) — **版本 ↔ tag / 提交 / 封装包 / 总结 对照（含 tag 缺口与补挂建议）**
6. [docs\【重要必读】修改UI后卡在旧加载界面.md](docs/【重要必读】修改UI后卡在旧加载界面.md) — UI 改动 boot-fail 快速排查卡

## 六、维护约定（摘要）

- **代码与总结同一次提交推送**；提交信息简短中文，一批修改一个提交。
- **游戏逻辑改动两步走**：改 `decompiled` 源码 + 登记 `config\build\swf-script-patches.txt`，漏登记不生效；FFDec 回读验证为标准动作。
- **bat 纪律**：根目录 BAT/EXE 是玩家入口勿动；全部 .bat 保持 CRLF（LF 工作副本会引发 cmd 解析错位，20260920 事故实锤）。
- **公告纪律**：致谢名单只许追加、严禁删减；公告文件随 APK 发布，改公告须重出包。
- **打包纪律**：封装先落 ASCII 目录再入归集文件夹；测试归集目录自动只留最新；**测试包只进 `临时封装目录\手游端\测试\`，绝不进 `3.x.x\` 正式归集位**（20260923 红线，详见临时封装目录 README 第二节第 7 条）；发版选号前核对版本号未被未发行版本占用（3.0.5 已被占用）。

## 七、工作档案（给将来接手的开发者）

1. 本仓 git 历史是端游历史的前缀（`ba10543` → `7e28a5e` 停住），手游 1.x 适配成果曾长期以未提交改动形态存在，2026-09-15 以 `71fae81` 保全落地；
2. 曾尝试"瘦身：只留移动层"（`a5be734`）当日撤回（`c11fa01`），恢复独立完整副本——手游必须独立演进；瘦身期间删除的约 4G 历史包备份在冷备 `F:\超合金冷数据备份\手机版本归档\`；
3. **2026-09-20 完成对齐端游 3.0 的移植总工程**：F-8 着色清扫五刀、L1 外围换新、L2 四件资源整收、L3-1~L3-11 逐项移植、批 1~2 散件与加固、批 3~5 核对收口、批 6 发布 3.0.3。全过程与决策见 [移植台账.md](移植台账.md) 与 `D:\superalloy\TMP\手游3.03 TMP工作任务整理\`；
4. 版本号策略：1.0~1.2.5 为独立计数时代；自 3.0.3 起与端游同步，此后版本号随端游更新。
