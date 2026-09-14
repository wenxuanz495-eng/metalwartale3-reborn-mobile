# Android AIR test package

This is an isolated packaging harness for the current SWF. It stages `build/game.swf`
and the runtime SWF tree into an AIR application, then creates a debug APK with Harman
AIR SDK 50.2.4.1.

The package is intended to validate AIR startup, fullscreen orientation, and ordinary
single-finger UI input. It does not yet replace the desktop Go save server or implement
virtual battle controls.

Set `AIR_SDK` to the extracted AIR SDK directory, then run:

```powershell
./build-apk.ps1
```

Use `-Arch x64` for a MuMu instance whose primary ABI is `x86_64`. The default
`armv7` package is intended for older physical Android devices.
