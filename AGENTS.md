# AGENTS.md — 手游仓协作规则（AI 必读）

> 2026-09-20 重写，替代 1.26 时代遗留版（旧版指向端游仓路径且内容过时，已删除）。
> 本文件是《超合金战记》**手游版仓库**的协作红线。约定：中文交流与注释；不确定先问，不猜。

## 仓库身份

- 本仓是《超合金战记》**手游版（AIR/Android）的独立完整仓库**：游戏本体（decompiled / SWF / server / launcher）与移动适配层（触屏、ANE、打包）都在本仓。
- **版本号自 3.0.3 起与端游同步**（此前 1.0~1.2.5 独立计数）；本版已同步端游 3.0 全部内容。
- 端游仓：`D:\superalloy\metalwartale3-reborn.git`（工程文档与端游侧更新总结的主文档区在端游侧）。
- 两仓关系：端游功能按批 cherry-pick 回移，**冲突时触屏基础 17 类以手游版为准**；进度唯一账本 = `移植台账.md`。

## 红线（按优先级）

1. **构建唯一入口** `构建.bat`（= `scripts\build_all.bat`，148 项清单驱动补丁构建）。游戏逻辑改动两步走：改 `decompiled` 源码 + 登记 `config\build\swf-script-patches.txt`（新增 .as 类必须登记才导入），漏登记不生效；改后 FFDec 回读验证进 `build\game.swf`。
2. **根目录 .bat 与 exe 是玩家入口**：不移动、不重命名、不合并。.bat 保持 CRLF——工作副本若为 LF，配合中文与 chcp 65001 会导致 cmd 解析错位（20260920 事故实锤，两仓 20 个 bat 已归一）。
3. **.as 文件为 CRLF/混合行尾**：编辑一律用 Python 字节级替换 + 锚点断言，禁止 heredoc 与直写转义。
4. **FFDec 改 SWF 三条**：克隆符号必须同步 SymbolClass 类绑定（否则 #1034 boot-fail 卡 fase 屏）；克隆闭包纳入位图引用；swf2xml → 改 → xml2swf → 回读归一化全等验证。ui1120.swf 为双层压缩容器，手工解析不可行。
5. **测试包归档**：`临时封装目录\手游端\3.x.x\`（build-apk.ps1 自动命名、附 sha256、自动清旧仅留最新）；vivo 装机先亮屏解锁；MuMu 必须 OpenGL 且不能验证 gpu 着色。
6. **改动与文档同步**：行为修改必须同步 docs 与 `移植台账.md`；总结归档与代码同一次提交推送。
7. **只读与谨慎区**：`archive\` 只读；`decompiled\` 谨慎修改并走回读验证；`build\`、`logs\` 与 AI 工具缓存不入库；公告致谢名单只许追加严禁删减。
8. **日志与产物**：boot 失败看 `build\saves\client_errors.log` 与 logcat 末条业务 trace；真机 boot 诊断路径见端游仓 postmortems。

## 入口文档（按序阅读）

1. `README.md` — 仓库导航、运行架构、发布流程
2. `移植台账.md` — 端游→手游移植唯一进度账本（批 1~6 已全部关闭）
3. `移植README.md` — 移植作业规范（基线 / 三方对照 / 触屏 17 类 / 留底）
4. `docs\` — 工程文档（BAT_RUNTIME / PROJECT_STATUS / SEAL_RULES / 弹速维护提示等，承自端游）
5. `更新总结\` — bug 维护与已完成专项归档（含 README 索引）
