# Start Android emulator with software GPU (avoids exit code 1 from GPU/driver issues).
# Usage: .\scripts\run-emulator-software-gpu.ps1 [AVD_NAME]
# If AVD_NAME is omitted, uses the first AVD from emulator -list-avds.

$sdk = $env:LOCALAPPDATA
if (-not $sdk) { $sdk = "$env:USERPROFILE\AppData\Local" }
$emulator = "$sdk\Android\Sdk\emulator\emulator.exe"

if (-not (Test-Path $emulator)) {
    Write-Error "Emulator not found at: $emulator. Set ANDROID_HOME or ensure Android SDK is installed."
    exit 1
}

$avd = $args[0]
if (-not $avd) {
    $avds = & $emulator -list-avds 2>$null
    if (-not $avds) {
        Write-Error "No AVDs found. Create one in Android Studio (Device Manager)."
        exit 1
    }
    $avd = ($avds | Select-Object -First 1).Trim()
    Write-Host "Using AVD: $avd"
}

Write-Host "Starting emulator with software GPU (-gpu swiftshader_indirect)..."
& $emulator -avd $avd -gpu swiftshader_indirect
