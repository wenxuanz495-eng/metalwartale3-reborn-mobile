# 超合金战记 · 手游版（移动特有层）

> 本仓库**只包含手游特有层**：AIR/Android 打包工程（ANE、application.xml、打包脚本）与手游适配层补丁。
> 游戏本体（decompiled 源码、SWF 资源、Go 服务、构建基线）**不再在本仓库维护副本**，
> 由 `sync-from-desktop.ps1` 从端游仓库 `metalwartale3-reborn.git` 同步并叠加适配层后构建。
> 工程与玩法文档统一看端游仓库 `docs\` 与 `更新总结\`，本 README 只讲手游侧。

## 手游版本体系（独立计数，勿与端游混淆）

| 项 | 值 |
|---|---|
| 手游版本号 | 从 **1.0** 起独立计数，当前 **1.2.4**（`mobile\air-android\application.xml` 的 `versionNumber`） |
| 分裂基线 | 端游 **2.2.4 时代**（2026-08-07，提交 `7e28a5e`）——用户确认与记忆一致 |
| 适配层规模 | 87 文件，+4768/−330 行（提交 `71fae81`，补丁固化于 `patches\mobile-layer-7e28a5e.patch`） |

## 手游适配层里有什么

- **虚拟摇杆与触控**：`GamingUI.as`（move/aim 双摇杆、攻击钮、TouchEvent）、`KeysGroup.as`、`OneSkill.as`
- **AIR 存档**：`LocalSave.as`（`isAIRRuntime()` → `superalloy_mobile_save` 独立存储）、`SaveAPI.as`
- **移动端 UI 缩放适配**：各 Dialogbox/Shop/Gift/TopBox 界面
- **启动与打包适配**：`launch_game.bat`、`prepare_build_runtime.bat`、`start-*.bat`、`Copyright.as`、游戏公告
- **ANE**：`mobile\air-android\sasave-ane\`（AS3 + Java 桥，存档分享/来电动细）

## 同步构建流程

```text
端游仓库 HEAD
  → git worktree（work\desktop）
  → git apply -3  patches\mobile-layer-7e28a5e.patch   （叠加手游适配层）
  → 构建清单并集（端游 ∪ 手游，防补丁把清单拉回分叉时代）
  → scripts\build_swf.bat 构建 game.swf（FFDec 已随端游仓库入库）
  → build-apk.ps1 以 worktree 为 RepoRoot 打 APK（captive runtime）
```

一条命令：

```powershell
$env:AIR_SDK = "D:\superalloy\air-mobile-tools\airsdk-50.2.4.1"
powershell -File sync-from-desktop.ps1 -Package
```

产物：`work\desktop\build\game.swf` 与 `work\MOBILE-APK-READY\SuperAlloy-Mobile-Test-*.apk`。

## 冲突处理约定

适配层基线停留在端游 2.2.4 时代，端游演进后叠加可能冲突（`git apply -3` 会在 `work\` 留 `*.rej`）。
已知双方都动过的高危文件：`CtrlListCtrl.as`、`ChipCubeUI.as`、`ArmsItemsData.as`、`EventGroup.as`、`SWFLoaderManager.as`。
处理原则：**以端游新逻辑为底，把手游层的触控/存档/缩放改动重新落上去**；解决后在端游仓库或本补丁中固化，
并视情况更新补丁基线（重导出 patch 并更新本 README 的分裂基线记录）。

## 目录结构

```text
metalwartale3-reborn-mobile\
├── README.md                          本文件
├── sync-from-desktop.ps1              同步+构建编排脚本
├── patches\mobile-layer-7e28a5e.patch 手游适配层补丁（基线 7e28a5e）
├── mobile\air-android\                AIR 工程：application.xml(版本号在这)、sasave-ane\、bootstrap\、build-apk.ps1、stage\、dist\
└── work\                              同步构建工作区（gitignore，可随时删）
```

## 历史说明

本仓库原为端游仓库的完整副本（git 历史即端游历史前缀，**无独有提交**）。
2026-09-15 瘦身：游戏本体副本删除（需要时可从本仓库 git 历史或端游仓库取回），
独有价值固化为适配层补丁与本目录。旧手游构建日志、MOBILE-APK-READY 输出见
`F:\超合金冷数据备份\手机版本归档\`。
