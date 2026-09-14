# 手游同步构建脚本：从端游仓库同步游戏本体 + 叠加手游适配层 + 构建 game.swf
#
# 用法：
#   powershell -File sync-from-desktop.ps1                              # 同步+打补丁+构建 swf
#   powershell -File sync-from-desktop.ps1 -Package                     # 构建后继续打 APK（需 $env:AIR_SDK）
#   powershell -File sync-from-desktop.ps1 -DesktopRepo <端游仓库路径> -Ref <分支或提交>
#
# 模型说明（2026-09-15 瘦身裁定）：
#   手游仓不再养游戏本体副本（decompiled/swf/server 等已删除）。
#   每次同步 = 端游 worktree + 叠加 patches\mobile-layer-7e28a5e.patch（手游适配层：
#   虚拟摇杆/AIR存档/移动端UI/启动打包脚本/配置清单，基线=端游 2.2.4 时代 7e28a5e，2026-08-07）。
#   补丁与端游演进冲突时（git apply -3 冲突），按 work\*.rej 逐个手工合并——
#   冲突集中在中途双方都改过的文件（CtrlListCtrl/ChipCubeUI/ArmsItemsData/EventGroup 等）。

param(
    [string]$DesktopRepo = "D:\superalloy\metalwartale3-reborn.git",
    [string]$Ref = "HEAD",
    [switch]$Package,
    [string]$Arch = 'armv8'
)
$ErrorActionPreference = 'Stop'
$Patch = Join-Path $PSScriptRoot 'patches\mobile-layer-7e28a5e.patch'
$Work  = Join-Path $PSScriptRoot 'work\desktop'
if (!(Test-Path $DesktopRepo)) { throw "端游仓库不存在：$DesktopRepo" }
if (!(Test-Path $Patch)) { throw "适配层补丁不存在：$Patch" }

# 1) 端游 worktree（复用，每次硬重置到 Ref）
Write-Host "==== [1/5] 准备端游 worktree：$Ref ===="
$wt = git -C $DesktopRepo worktree list
if ($wt -match [regex]::Escape($Work)) {
    git -C $Work reset --hard $Ref | Out-Null
    git -C $Work clean -fdx | Out-Null
} else {
    git -C $DesktopRepo worktree add --detach $Work $Ref | Out-Null
}

# 2) 叠加手游适配层（三方应用）
Write-Host "==== [2/5] 叠加手游适配层补丁 ===="
git -C $Work apply -3 $Patch
if ($LASTEXITCODE -ne 0) { throw "补丁存在冲突：请按 $Work 下 *.rej 手工合并后重跑" }

# 3) 清单合并：补丁会把清单替换回分叉时代版本，这里做并集（端游条目优先，手游独有条目追加）
Write-Host "==== [3/5] 构建清单并集（端游 ∪ 手游）===="
foreach ($name in @('swf-script-patches.txt','swf-binary-patches.txt')) {
    $rel = Join-Path 'config\build' $name
    $desktopLines = git -C $DesktopRepo show "$Ref`:$($rel -replace '\\','/')" 2>$null
    if ($null -eq $desktopLines) { continue }
    $mobileLines = Get-Content (Join-Path $Work $rel) -ErrorAction SilentlyContinue
    if ($null -eq $mobileLines) { continue }
    $union = @($desktopLines) + @($mobileLines | Where-Object { $desktopLines -notcontains $_ })
    Set-Content -Path (Join-Path $Work $rel) -Value $union -Encoding UTF8
    Write-Host "  [并集] $rel（端游 $(@($desktopLines).Count) 行 ∪ 手游独有 $(@($union).Count - @($desktopLines).Count) 行）"
}

# 4) 构建 game.swf（端游构建管线，FFDec 已随仓库入库）
Write-Host "==== [4/5] 构建 game.swf ===="
Push-Location $Work
cmd /c "scripts\build_swf.bat" | Select-Object -Last 6
$buildExit = $LASTEXITCODE
Pop-Location
if ($buildExit -ne 0 -and $buildExit -lt 8) { } elseif ($buildExit -ge 8) { throw "构建失败 exit=$buildExit" }
if (!(Test-Path (Join-Path $Work 'build\game.swf'))) { throw "未见构建产物 build\game.swf" }
Write-Host "  [OK] $($Work)\build\game.swf"

# 5) 可选：打包 APK（build-apk.ps1 以 worktree 为 RepoRoot，自动取 build/runtime/assets）
if ($Package) {
    Write-Host "==== [5/5] 打包 APK ===="
    if ([string]::IsNullOrWhiteSpace($env:AIR_SDK)) { throw '请先 $env:AIR_SDK="D:\superalloy\air-mobile-tools\airsdk-50.2.4.1"' }
    & (Join-Path $PSScriptRoot 'mobile\air-android\build-apk.ps1') -RepoRoot $Work -Arch $Arch
} else {
    Write-Host "==== [5/5] 跳过 APK（加 -Package 打包）===="
}
Write-Host "完成。worktree=$Work（手游产物与 APK 均在其内；APK 在 work\MOBILE-APK-READY\）"
