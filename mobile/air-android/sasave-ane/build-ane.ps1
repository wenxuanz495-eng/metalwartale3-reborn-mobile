param([string]$AirSdk = $env:AIR_SDK)

$ErrorActionPreference = 'Stop'
if ([string]::IsNullOrWhiteSpace($AirSdk)) { throw 'AIR_SDK is not set.' }
$root = $PSScriptRoot
$build = Join-Path $root 'build'
$classes = Join-Path $build 'classes'
$android = 'D:\superalloy\工具\air-mobile-tools\android-4.1.1.4.jar'
$fre = Join-Path $AirSdk 'lib\android\FlashRuntimeExtensions.jar'
$json = 'D:\superalloy\工具\air-mobile-tools\json-20231013.jar'
$airglobal = Join-Path $AirSdk 'frameworks\libs\air\airglobal.swc'
$jdk8 = 'D:\superalloy\工具\air-mobile-tools\jdk8\jdk8u502-b07\bin'
$swc = Join-Path $build 'sasave.swc'
$ane = Join-Path $root 'sasave.ane'

New-Item -ItemType Directory -Force $build,$classes | Out-Null
Get-ChildItem $classes -Force -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force
& (Join-Path $AirSdk 'bin\acompc.bat') -swf-version=16 -source-path (Join-Path $root 'as3') -include-classes com.superalloy.sasave.SasaveExtension -external-library-path $airglobal -output $swc
if ($LASTEXITCODE -ne 0) { throw 'AS3 ANE library build failed.' }

$javaFiles = Get-ChildItem (Join-Path $root 'java') -Recurse -Filter '*.java' | ForEach-Object FullName
& (Join-Path $jdk8 'javac.exe') -encoding UTF-8 -source 1.7 -target 1.7 -cp "$android;$fre;$json" -d $classes $javaFiles
if ($LASTEXITCODE -ne 0) { throw 'ANE Java build failed.' }
& (Join-Path $jdk8 'jar.exe') cf (Join-Path $build 'sasave.jar') -C $classes .

$platform = Join-Path $build 'platform'
New-Item -ItemType Directory -Force $platform | Out-Null
Copy-Item (Join-Path $build 'sasave.jar') (Join-Path $platform 'sasave.jar') -Force
$swcExtract = Join-Path $build 'swc-extract'
New-Item -ItemType Directory -Force $swcExtract | Out-Null
Push-Location $swcExtract
& (Join-Path $jdk8 'jar.exe') xf $swc library.swf
Pop-Location
Copy-Item (Join-Path $swcExtract 'library.swf') (Join-Path $platform 'library.swf') -Force
if (Test-Path $ane) { Remove-Item $ane -Force }
& (Join-Path $AirSdk 'bin\adt.bat') -package -target ane $ane (Join-Path $root 'extension.xml') -swc $swc -platform Android-ARM -C $platform library.swf sasave.jar -platform Android-ARM64 -C $platform library.swf sasave.jar -platform Android-x86 -C $platform library.swf sasave.jar -platform Android-x64 -C $platform library.swf sasave.jar
if ($LASTEXITCODE -ne 0) { throw 'ANE packaging failed.' }
Get-Item $ane | Select-Object FullName,Length,LastWriteTime
