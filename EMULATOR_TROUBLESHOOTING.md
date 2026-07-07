# Android Emulator Exit Code 1 – Troubleshooting

When the emulator exits with code 1 and shows "Address these issues and try again", the real cause is often **graphics/GPU** or **virtualization**. Use the steps below.

---

## 1. See the actual error (recommended first step)

In PowerShell, run the emulator with verbose output so you get the real error:

```powershell
$env:LOCALAPPDATA = $env:LOCALAPPDATA ?? "$env:USERPROFILE\AppData\Local"
& "$env:LOCALAPPDATA\Android\Sdk\emulator\emulator.exe" -avd Resizable_Experimental_API_34 -verbose 2>&1
```

(Replace `Resizable_Experimental_API_34` with your AVD name from `emulator -list-avds`.)

Check the last lines of the output for the exact error message.

---

## 2. Use software graphics (fixes most GPU-related exit code 1)

### Option A: Run with script (quick test)

From the project folder:

```powershell
.\scripts\run-emulator-software-gpu.ps1
```

This starts the emulator with software GPU. If it starts successfully, the problem is likely your GPU/drivers.

### Option B: Change AVD to Software in Android Studio

1. Open **Android Studio** → **Device Manager** (or **Tools** → **Device Manager**).
2. Click the **pencil (Edit)** on your AVD.
3. Click **Show Advanced Settings**.
4. Under **Emulated Performance** → **Graphics**, choose **Software - GLES 2.0**.
5. Finish and start the AVD again.

### Option C: Command line with software GPU

```powershell
& "$env:LOCALAPPDATA\Android\Sdk\emulator\emulator.exe" -avd Resizable_Experimental_API_34 -gpu swiftshader_indirect
```

---

## 3. Windows: virtualization and features

- **Turn on:** **Windows Features** → enable **Windows Hypervisor Platform** (and **Hyper-V** if you use it).
- **Restart** after changing these.
- If you use **WSL2**, Hyper-V is usually already on; the emulator should use the Windows Hypervisor.

---

## 4. Other checks

| Check | What to do |
|-------|------------|
| **Free disk space** | Keep at least **5 GB** free. |
| **RAM** | Close heavy apps; emulator needs several GB. |
| **Antivirus** | Add the Android SDK folder (e.g. `%LOCALAPPDATA%\Android\Sdk`) to exclusions, or temporarily disable to test. |
| **GPU drivers** | Update to the latest from your PC/GPU vendor. |
| **Corrupt AVD** | In Device Manager, **Wipe Data** for the AVD or create a new AVD. |

---

## 5. After fixing: run the app

Start the emulator (e.g. with the script or from Android Studio), then run your app:

```bash
flutter run
```

Or run/debug from your IDE with the emulator already running.
