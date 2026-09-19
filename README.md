# 超合金战记 · 手游版（metalwartale3-reborn-mobile）

> 本仓库是《超合金战记》**手游版**（AIR/Android）的**独立完整仓库**：
> 游戏本体（decompiled 源码 / SWF 资源 / Go 服务 / 构建管线）与移动特有层（ANE、触控、打包）都在本仓内，
> **独立版本号、独立演进**，不与端游仓库自动同步。
> 端游仓库：`D:\superalloy\metalwartale3-reborn.git`（工程文档与更新总结的主文档区在那边）。
>
> **移植进行中（20260920 立项）**：现状快照、双仓差距实测（端游 290 提交差距 / 95 类双改冲突面 / 4 件资源 SWF 分叉）、
> 触控基线红线与 L1→L3 分层移植路线，见 **[移植README.md](移植README.md)**。⚠️ 触控基础系统为基线，任何移植动作不得覆盖。

## 一、版本体系（独立计数，勿与端游混淆）

| 项 | 值 |
|---|---|
| 手游版本号 | **从 1.0 起独立计数**，当前 **1.2.4**（`mobile\air-android\application.xml` 的 `versionNumber`，随版本更新此处） |
| 与端游的分叉 | 游戏本体分叉自端游 **2.2.4 时代**（基线提交 `7e28a5e`，2026-08-07） |
| 演进策略 | **保持独立**：端游的功能/特效更新不自动同步，按需人工挑选回移；手游无法跟进的保持现状。存档与端游互通为既定方向（待实现验证） |

## 二、手游适配层（本仓特有，端游没有的部分）

| 模块 | 文件 | 内容 |
|---|---|---|
| 虚拟摇杆与触控 | `decompiled\...\UI\gaming\GamingUI.as`、`body\key\KeysGroup.as`、`body\skill\OneSkill.as` | move/aim 双摇杆、攻击钮、TouchEvent、技能触控 |
| AIR 存档 | `gameAll\api\save\LocalSave.as`、`SaveAPI.as`、`mobile\air-android\sasave-ane\` | `isAIRRuntime()` → `superalloy_mobile_save` 独立存储；ANE 桥（存档分享/来电动细） |
| 移动端 UI 缩放 | 各 `Dialogbox*`、`Shop`、`Gift`、`TopDialogBox` 等 | 小屏界面缩放与布局适配 |
| 启动与打包 | `scripts\launch_game.bat`、`prepare_build_runtime.bat`、`start-*.bat`、`Copyright.as` | 手游启动链与版权页适配 |
| 独立构建清单 | `config\build\swf-script-patches.txt`（97 项，独立于端游 122 项） | 手游自己的最小补丁清单 |

## 三、构建与打包

| 动作 | 命令 |
|---|---|
| 全量构建 game.swf | [`构建.bat`](构建.bat)（= `scripts\build_all.bat`，清单驱动补丁构建，产物 `build\game.swf`） |
| 本地试玩 | `启动游戏-flashplayer_sa.bat` / `_debug.bat` |
| 打 APK | `$env:AIR_SDK="D:\superalloy\工具\air-mobile-tools\airsdk-50.2.4.1"` 后运行 `mobile\air-android\build-apk.ps1`（支持 `-Arch armv7/armv8/x86/x64`、`-Release`；captive runtime） |
| 重编 ANE | `mobile\air-android\sasave-ane\build-ane.ps1` |

APK 产物输出到工作区根 `MOBILE-APK-READY\`；签名证书 `test-release.p12`（首跑自动生成，密码 `superalloy-test`，勿入库）。

## 四、目录导航

```text
metalwartale3-reborn-mobile\
├── mobile\air-android\        手游特有层：application.xml(版本号)、sasave-ane\、bootstrap\、build-apk.ps1、stage\、dist\
├── decompiled\                游戏逻辑源码（含手游适配层改动）
├── swf\                       分包 SWF 源资源与构建基线
├── server\ / launcher\        本地 Go 服务与启动器源码
├── config\ scripts\           构建清单与构建/自检脚本
├── docs\ runtime\ assets\     文档、运行时资源、UI 素材
├── build\ preview\ release\ backups\   构建产物与历史包（本地生成/留存）
└── 根目录 BAT/EXE             启动、修改器、存档维护入口
```

## 五、工作档案（2026-09-15，给将来接手的开发者）

1. **本仓的 git 历史是端游历史的前缀**（`ba10543 initial commit` → `7e28a5e`），在 `7e28a5e`（2026-08-07，端游 2.2.4 之后）处停住，**没有独有的已提交内容**；
2. 手游 1.x 的全部适配成果曾长期以 **未提交工作区改动** 形态存在（一度 66 项、87 文件 +4768/−330，含此前未入库的 ANE 源码与素材），2026-09-15 以提交 **`71fae81`** 保全落地——在此之前一次误操作就可能清空它；
3. 同日曾尝试"瘦身：只留移动层、游戏本体从端游同步"（提交 `a5be734`，含 `sync-from-desktop.ps1` 与 `patches\mobile-layer-7e28a5e.patch`），**当日撤回**（revert），恢复独立完整副本。理由：端游更新特效/功能时手游端可能无法跟进，手游必须保持独立演进而非依赖端游产物；
4. 瘦身尝试期间删除过约 4G **未纳入 git** 的构建/预览/发行/备份产物（`git revert` 无法恢复）。同类历史包的备份见冷备 `F:\超合金冷数据备份\手机版本归档\`（`metalwartale3-mobile-folder-backup-20260812`、`移动端输出-20260819`）；`sync-from-desktop.ps1` 与补丁文件如需取回，见本仓 git 历史 `a5be734`；
5. 端游仓库近期的芯片合成复制 bug 修复（`4cf084c`）等改动**不在**本仓，需要回移时按"适配层优先、以手游独立运行为准"逐项评估。
