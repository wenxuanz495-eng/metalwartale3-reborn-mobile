param(
    [string]$AirSdk = $env:AIR_SDK,
    [string]$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path,
    [ValidateSet('armv7','armv8','x86','x64')]
    [string]$Arch = 'armv7',
    [switch]$Release
)

$ErrorActionPreference = 'Stop'
if ([string]::IsNullOrWhiteSpace($AirSdk)) {
    throw 'AIR_SDK is not set. Example: $env:AIR_SDK="D:\\superalloy\\工具\\air-mobile-tools\\airsdk-50.2.4.1"'
}
$adt = Join-Path $AirSdk 'bin\adt.bat'
if (!(Test-Path $adt)) { throw "adt not found: $adt" }

$project = $PSScriptRoot
$stage = Join-Path $project 'stage'
$workspaceRoot = Split-Path $RepoRoot -Parent
$out = Join-Path $workspaceRoot 'MOBILE-APK-READY'
$cert = Join-Path $project 'test-release.p12'
$extensions = Join-Path $project 'sasave-ane'
New-Item -ItemType Directory -Force $stage,$out | Out-Null
if (Test-Path $stage) { Get-ChildItem $stage -Force | Remove-Item -Recurse -Force }
Copy-Item (Join-Path $RepoRoot 'build\game.swf') (Join-Path $stage 'game.swf')
Copy-Item (Join-Path $RepoRoot 'runtime\swf') (Join-Path $stage 'swf') -Recurse
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
$args = @('-package', '-target', $(if ($Release) { 'apk' } else { 'apk-debug' }), '-arch', $Arch, '-storetype', 'pkcs12', '-keystore', $cert, '-storepass', 'superalloy-test', $target, (Join-Path $project 'application.xml'), '-extdir', $extensions, '-C', $stage, 'game.swf', '-C', $stage, 'swf', '-C', $stage, 'ui')
& $adt @args
if ($LASTEXITCODE -ne 0) { throw "adt package failed: $LASTEXITCODE" }
Get-Item $target | Select-Object FullName,Length,LastWriteTime
