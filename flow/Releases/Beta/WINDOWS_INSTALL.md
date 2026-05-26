# Windows Installation Guide (WSL)

Flow currently runs on Windows through **WSL (Windows Subsystem for Linux)**.

The current Flow Linux build is a GNU/Linux binary, so Windows users should install Ubuntu on WSL and run Flow inside the WSL terminal.

> Git Bash is not supported for this release. Git Bash is not a full Linux environment and cannot run the current Linux ELF binary directly.

---

## Requirements

- Windows 10 or Windows 11
- Internet connection
- PowerShell or Windows Terminal
- Ubuntu installed through WSL

---

## 1. Install WSL with Ubuntu

Open **PowerShell as Administrator**.

To do that:

1. Click the Windows **Start** button.
2. Search for **PowerShell**.
3. Right-click **Windows PowerShell**.
4. Click **Run as administrator**.

Then run:

```powershell
wsl --install -d Ubuntu
```

If Windows asks you to restart, restart your computer.

---

## 2. Open Ubuntu / WSL

After installation, open **PowerShell** again and run:

```powershell
wsl
```

You should see a Linux terminal prompt similar to this:

```bash
user@LAPTOP:/mnt/c/Users/user$
```

That means you are now inside Ubuntu on WSL.

The first time you open Ubuntu, it may ask you to create a Linux username and password.

---

## 3. Go to your Linux home folder

Inside WSL, run:

```bash
cd ~
```

This moves you to your Linux home directory.

---

## 4. Download Flow

Replace the URL below with the real Flow release download link from GitHub or download lunix version.

```bash
curl -L -o flow https://github.com/linthantkyaw2002/Easyshell/tree/main/flow/Releases/Beta/flowBeta0.1.0-linux-x86_64
```

---

## 5. Make install.sh executable

```bash
chmod +x install.sh 
```
## 6. Run install.sh

```bash
chmod +x install.sh 
```

---

## If `wsl --install -d Ubuntu` does not work

Some Windows systems need WSL enabled manually.

Open **PowerShell as Administrator** and run:

```powershell
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
```

Then restart your computer.

After restarting:

1. Open the **Microsoft Store**.
2. Search for **Ubuntu**.
3. Install Ubuntu.
4. Open PowerShell and run:

```powershell
wsl
```

Then continue from step 3 above.

---

## Uninstall Flow from WSL

## 1. Make uninstall.sh executable

```bash
chmod +x uninstall.sh 
```
## 6. Run uninstall.sh

```bash
chmod +x uninstall.sh 

---

## Notes

- Flow must be installed and run **inside WSL**, not directly in Windows PowerShell.
- Windows files are available inside WSL under `/mnt/c/`.
- Example Windows Downloads folder path inside WSL:
