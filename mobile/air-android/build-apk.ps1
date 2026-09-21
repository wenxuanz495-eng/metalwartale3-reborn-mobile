param(
    [string]$AirSdk = $env:AIR_SDK,
    [string]$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path,
    [ValidateSet('armv7','armv8','x86','x64')]
    [string]$Arch = 'armv7',
    [switch]$Release,
    [string]$Theme = '',
    [string]$OutDir = ''
)

$ErrorActionPreference = 'Stop'
if ([string]::IsNullOrWhiteSpace($AirSdk)) {
    throw 'AIR_SDK is not set. Example: $env:AIR_SDK="D:\superalloy\工具\air-mobile-tools\airsdk-50.2.4.1"'
}
$adt = Join-Path $AirSdk 'bin\adt.bat'
if (!(Test-Path $adt)) { throw "adt not found: $adt" }

$project = $PSScriptRoot
$stage = Join-Path $project 'stage'
$workspaceRoot = Split-Path $RepoRoot -Parent
# adt 对中文路径存在代码页坑（见移植台账/交接沉淀）：封装先落本仓 ASCII 目录 dist\，
# 成功后自动改名搬入测试归集文件夹并生成 .sha256.txt。
$out = Join-Path $project 'dist'
$deliverDir = Join-Path $workspaceRoot '临时封装目录\手游端\3.x.x'
if (![string]::IsNullOrWhiteSpace($OutDir)) { $deliverDir = $OutDir }
$cert = Join-Path $project 'test-release.p12'
$extensions = Join-Path $project 'sasave-ane'
New-Item -ItemType Directory -Force $stage,$out | Out-Null
if (Test-Path $stage) { Get-ChildItem $stage -Force | Remove-Item -Recurse -Force }
Copy-Item (Join-Path $RepoRoot 'build\game.swf') (Join-Path $stage 'game.swf')
Copy-Item (Join-Path $RepoRoot 'build\swf') (Join-Path $stage 'swf') -Recurse
Copy-Item (Join-Path $RepoRoot 'runtime\游戏更新公告.txt') (Join-Path $stage 'notice_update.txt')
Copy-Item (Join-Path $RepoRoot 'runtime\感谢公告.txt') (Join-Path $stage 'notice_thanks.txt')
$supportSource = Join-Path $RepoRoot 'build\ui\support\afdian-support.jpg'
$supportStage = Join-Path $stage 'ui\support'
if (!(Test-Path $supportSource)) { throw "support QR image not found: $supportSource" }
New-Item -ItemType Directory -Force $supportStage | Out-Null
Copy-Item $supportSource (Join-Path $supportStage 'afdian-support.jpg')
$uiAssets = @(
    'ui\pause-settings\button-normal.png',
    'ui\pause-settings\button-hover.png',
    'ui\auto-level\button-normal.png',
    'ui\auto-level\button-selected.png',
    'ui\save-data\save-data-up.png',
    'ui\save-data\save-data-over.png'
)
foreach ($uiAsset in $uiAssets) {
    $assetSource = Join-Path (Join-Path $RepoRoot 'assets') $uiAsset
    $assetTarget = Join-Path $stage $uiAsset
    if (!(Test-Path $assetSource)) { throw "UI asset not found: $assetSource" }
    New-Item -ItemType Directory -Force (Split-Path $assetTarget -Parent) | Out-Null
    Copy-Item $assetSource $assetTarget
}

if (!(Test-Path $cert)) {
    & $adt -certificate -cn 'SuperAlloy Mobile Test' 2048-RSA $cert 'superalloy-test' | Write-Host
    if ($LASTEXITCODE -ne 0) { throw "adt certificate failed: $LASTEXITCODE" }
}

$target = Join-Path $out ("SuperAlloy-Mobile-Test-$Arch-" + $(if ($Release) { 'release.apk' } else { 'debug.apk' }))
if (Test-Path $target) { Remove-Item $target -Force }
$args = @('-package', '-target', $(if ($Release) { 'apk' } else { 'apk-debug' }), '-arch', $Arch, '-storetype', 'pkcs12', '-keystore', $cert, '-storepass', 'superalloy-test', $target, (Join-Path $project 'application.xml'), '-extdir', $extensions, '-C', $stage, 'game.swf', '-C', $stage, 'swf', '-C', $stage, 'ui', '-C', $stage, 'notice_update.txt', '-C', $stage, 'notice_thanks.txt')
& $adt @args
if ($LASTEXITCODE -ne 0) { throw "adt package failed: $LASTEXITCODE" }

$version = '1.2.4'
$appXml = Join-Path $project 'application.xml'
if (Test-Path $appXml) {
    $m = Select-String -Path $appXml -Pattern '<versionNumber>([0-9.]+)</versionNumber>' | Select-Object -First 1
    if ($m) { $version = $m.Matches[0].Groups[1].Value }
}
$date0 = Get-Date -Format 'yyyyMMdd'
$nameParts = @('SuperAlloy-Mobile', $version)
if (![string]::IsNullOrWhiteSpace($Theme)) { $nameParts += $Theme }
$nameParts += @($date0, $Arch, $(if ($Release) { 'release.apk' } else { 'debug.apk' }))
$finalName = $nameParts -join '-'

New-Item -ItemType Directory -Force $deliverDir | Out-Null
$finalPath = Join-Path $deliverDir $finalName
Move-Item $target $finalPath -Force
$hash = (Get-FileHash -Algorithm SHA256 $finalPath).Hash
[IO.File]::WriteAllText($finalPath + '.sha256.txt', $hash + '  ' + (Split-Path $finalPath -Leaf), [Text.UTF8Encoding]::new($false))
# 归集目录只保留最新一个安装包（用户裁定）：删除本次交付以外的 apk 与其 sha256 文件
# 注意：必须同时排除本次的 .sha256.txt，否则会把刚生成的校验件一并删掉（其 Name 也匹配 '*.apk.sha256.txt'）
$finalSha = $finalPath + '.sha256.txt'
Get-ChildItem -Path $deliverDir -File | Where-Object { $_.FullName -ne $finalPath -and $_.FullName -ne $finalSha -and ($_.Extension -eq '.apk' -or $_.Name -like '*.apk.sha256.txt') } | Remove-Item -Force
Get-Item $finalPath | Select-Object FullName,Length,LastWriteTime
Write-Host ("SHA256: " + $hash)
