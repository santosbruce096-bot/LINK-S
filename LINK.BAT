@echo off
title PC App Downloader GUI - Wide Layout

:: Auto-elevate to Administrator
net session >nul 2>&1
if %errorLevel% neq 0 (
    powershell -NoProfile -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b
)

:: Check winget
winget --version >nul 2>&1
if %errorLevel% neq 0 (
    powershell -NoProfile -Command "Add-Type -AssemblyName System.Windows.Forms; [System.Windows.Forms.MessageBox]::Show('Hindi nahanap ang winget. I-update muna ang App Installer sa Microsoft Store.', 'Error', 'OK', 'Error')"
    exit /b
)

:: Extract everything after # === GUI_START === into a temporary .ps1 file
set "PS_TEMP=%TEMP%\pc_app_wide_%RANDOM%.ps1"
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "$lines = Get-Content -LiteralPath '%~f0'; $idx = [array]::IndexOf($lines, '# === GUI_START ==='); if ($idx -ge 0) { $lines[($idx+1)..($lines.Length-1)] | Set-Content -LiteralPath '%PS_TEMP%' -Encoding UTF8 }"

if not exist "%PS_TEMP%" (
    echo [ERROR] Hindi na-extract ang GUI script.
    pause
    exit /b
)

powershell -NoProfile -ExecutionPolicy Bypass -STA -File "%PS_TEMP%"
set "PS_ERR=%errorLevel%"
del /f /q "%PS_TEMP%" >nul 2>&1

if %PS_ERR% neq 0 (
    echo.
    echo [ERROR] Nag-crash ang GUI script (Exit Code: %PS_ERR%).
    pause
)
exit /b

# === GUI_START ===
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

[System.Windows.Forms.Application]::EnableVisualStyles()

# Main Widescreen Window
$form = New-Object System.Windows.Forms.Form
$form.Text = "PC App Downloader v5 - Wide Dashboard Layout"
$form.Size = New-Object System.Drawing.Size(760, 560)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = "FixedDialog"
$form.MaximizeBox = $false
$form.BackColor = [System.Drawing.Color]::FromArgb(18, 20, 26)
$form.ForeColor = [System.Drawing.Color]::White
$form.Font = New-Object System.Drawing.Font("Segoe UI", 9.5)

# Top Banner Panel
$pnlTop = New-Object System.Windows.Forms.Panel
$pnlTop.Location = New-Object System.Drawing.Point(0, 0)
$pnlTop.Size = New-Object System.Drawing.Size(760, 52)
$pnlTop.BackColor = [System.Drawing.Color]::FromArgb(28, 32, 42)
$form.Controls.Add($pnlTop)

$lblBanner = New-Object System.Windows.Forms.Label
$lblBanner.Text = "PC APP DOWNLOADER  |  GAMING, EMULATION & UTILITIES"
$lblBanner.Location = New-Object System.Drawing.Point(20, 14)
$lblBanner.Size = New-Object System.Drawing.Size(520, 24)
$lblBanner.Font = New-Object System.Drawing.Font("Segoe UI Semibold", 11.5)
$lblBanner.ForeColor = [System.Drawing.Color]::FromArgb(0, 215, 255)
$pnlTop.Controls.Add($lblBanner)

$lblSub = New-Object System.Windows.Forms.Label
$lblSub.Text = "Queue Mode Active"
$lblSub.Location = New-Object System.Drawing.Point(615, 17)
$lblSub.Size = New-Object System.Drawing.Size(120, 20)
$lblSub.ForeColor = [System.Drawing.Color]::FromArgb(120, 240, 170)
$pnlTop.Controls.Add($lblSub)

# App Lists
$gamingApps = @(
    @{ Name = "Steam"; ID = "Valve.Steam" },
    @{ Name = "Discord"; ID = "Discord.Discord" },
    @{ Name = "OBS Studio"; ID = "OBSProject.OBSStudio" },
    @{ Name = "RetroArch (Multi-Emulator)"; ID = "Libretro.RetroArch" },
    @{ Name = "DuckStation (PS1 Emulator)"; ID = "stenzek.DuckStation" },
    @{ Name = "PCSX2 (PS2 Emulator)"; ID = "PCSX2Team.PCSX2" },
    @{ Name = "DirectX End-User Runtime"; ID = "Microsoft.DirectX" }
)

$utilApps = @(
    @{ Name = "Google Chrome"; ID = "Google.Chrome" },
    @{ Name = "7-Zip"; ID = "7zip.7zip" },
    @{ Name = "VLC Media Player"; ID = "VideoLAN.VLC" },
    @{ Name = "Notepad++"; ID = "Notepad++.Notepad++" },
    @{ Name = "Everything Search"; ID = "voidtools.Everything" },
    @{ Name = "Microsoft PowerToys"; ID = "Microsoft.PowerToys" }
)

$checkboxes = @()

# Left Column: Gaming & Emulation
$grpGaming = New-Object System.Windows.Forms.GroupBox
$grpGaming.Text = " Gaming & Emulation "
$grpGaming.Location = New-Object System.Drawing.Point(20, 66)
$grpGaming.Size = New-Object System.Drawing.Size(265, 255)
$grpGaming.ForeColor = [System.Drawing.Color]::FromArgb(120, 215, 255)
$form.Controls.Add($grpGaming)

$y = 26
foreach ($app in $gamingApps) {
    $cb = New-Object System.Windows.Forms.CheckBox
    $cb.Text = $app.Name
    $cb.Tag = @{ Name = $app.Name; ID = $app.ID; Category = "Gaming" }
    $cb.Location = New-Object System.Drawing.Point(14, $y)
    $cb.Size = New-Object System.Drawing.Size(240, 24)
    $cb.ForeColor = [System.Drawing.Color]::White
    $grpGaming.Controls.Add($cb)
    $checkboxes += $cb
    $y += 30
}

# Middle Column: PC Utilities
$grpUtils = New-Object System.Windows.Forms.GroupBox
$grpUtils.Text = " PC Utilities & Browser "
$grpUtils.Location = New-Object System.Drawing.Point(300, 66)
$grpUtils.Size = New-Object System.Drawing.Size(235, 255)
$grpUtils.ForeColor = [System.Drawing.Color]::FromArgb(120, 215, 255)
$form.Controls.Add($grpUtils)

$y = 26
foreach ($app in $utilApps) {
    $cb = New-Object System.Windows.Forms.CheckBox
    $cb.Text = $app.Name
    $cb.Tag = @{ Name = $app.Name; ID = $app.ID; Category = "Utils" }
    $cb.Location = New-Object System.Drawing.Point(14, $y)
    $cb.Size = New-Object System.Drawing.Size(210, 24)
    $cb.ForeColor = [System.Drawing.Color]::White
    $grpUtils.Controls.Add($cb)
    $checkboxes += $cb
    $y += 30
}

# Right Column: Quick Browser Shortcuts & Controls
$grpRight = New-Object System.Windows.Forms.GroupBox
$grpRight.Text = " Quick Sites & Actions "
$grpRight.Location = New-Object System.Drawing.Point(550, 66)
$grpRight.Size = New-Object System.Drawing.Size(185, 255)
$grpRight.ForeColor = [System.Drawing.Color]::FromArgb(255, 200, 90)
$form.Controls.Add($grpRight)

$sites = @(
    @{ Label = "Open 1Flex"; Url = "https://www.1flex.org/" },
    @{ Label = "Open 1Tube"; Url = "https://www.1tube.org/" },
    @{ Label = "Open FMovies"; Url = "https://fmovies-hd.to/home/" },
    @{ Label = "Open AG48Anime"; Url = "https://www.ag48anime.fun/" }
)

$sy = 26
foreach ($s in $sites) {
    $btnSite = New-Object System.Windows.Forms.Button
    $btnSite.Text = $s.Label
    $btnSite.Tag = $s.Url
    $btnSite.Location = New-Object System.Drawing.Point(15, $sy)
    $btnSite.Size = New-Object System.Drawing.Size(155, 28)
    $btnSite.BackColor = [System.Drawing.Color]::FromArgb(38, 44, 58)
    $btnSite.ForeColor = [System.Drawing.Color]::White
    $btnSite.FlatStyle = "Flat"
    $btnSite.Add_Click({ Start-Process $this.Tag })
    $grpRight.Controls.Add($btnSite)
    $sy += 34
}

$btnSelAll = New-Object System.Windows.Forms.Button
$btnSelAll.Text = "Select All Apps"
$btnSelAll.Location = New-Object System.Drawing.Point(15, 170)
$btnSelAll.Size = New-Object System.Drawing.Size(155, 28)
$btnSelAll.BackColor = [System.Drawing.Color]::FromArgb(35, 75, 65)
$btnSelAll.ForeColor = [System.Drawing.Color]::White
$btnSelAll.FlatStyle = "Flat"
$btnSelAll.Add_Click({ foreach ($cb in $checkboxes) { $cb.Checked = $true } })
$grpRight.Controls.Add($btnSelAll)

$btnClearAll = New-Object System.Windows.Forms.Button
$btnClearAll.Text = "Clear Selection"
$btnClearAll.Location = New-Object System.Drawing.Point(15, 206)
$btnClearAll.Size = New-Object System.Drawing.Size(155, 28)
$btnClearAll.BackColor = [System.Drawing.Color]::FromArgb(80, 40, 45)
$btnClearAll.ForeColor = [System.Drawing.Color]::White
$btnClearAll.FlatStyle = "Flat"
$btnClearAll.Add_Click({
    foreach ($cb in $checkboxes) { $cb.Checked = $false }
    $txtCustom.Text = ""
})
$grpRight.Controls.Add($btnClearAll)

# Custom Winget ID Row
$lblCustom = New-Object System.Windows.Forms.Label
$lblCustom.Text = "Custom Winget ID:"
$lblCustom.Location = New-Object System.Drawing.Point(20, 336)
$lblCustom.Size = New-Object System.Drawing.Size(130, 24)
$lblCustom.ForeColor = [System.Drawing.Color]::LightGray
$form.Controls.Add($lblCustom)

$txtCustom = New-Object System.Windows.Forms.TextBox
$txtCustom.Location = New-Object System.Drawing.Point(150, 334)
$txtCustom.Size = New-Object System.Drawing.Size(435, 26)
$txtCustom.BackColor = [System.Drawing.Color]::FromArgb(32, 36, 46)
$txtCustom.ForeColor = [System.Drawing.Color]::White
$txtCustom.BorderStyle = "FixedSingle"
$form.Controls.Add($txtCustom)

$btnStart = New-Object System.Windows.Forms.Button
$btnStart.Text = "Download Selected"
$btnStart.Location = New-Object System.Drawing.Point(595, 333)
$btnStart.Size = New-Object System.Drawing.Size(140, 28)
$btnStart.BackColor = [System.Drawing.Color]::FromArgb(0, 145, 220)
$btnStart.ForeColor = [System.Drawing.Color]::White
$btnStart.Font = New-Object System.Drawing.Font("Segoe UI Semibold", 9.5)
$btnStart.FlatStyle = "Flat"
$form.Controls.Add($btnStart)

# Bottom Console Log Panel
$txtLog = New-Object System.Windows.Forms.TextBox
$txtLog.Location = New-Object System.Drawing.Point(20, 374)
$txtLog.Size = New-Object System.Drawing.Size(715, 132)
$txtLog.Multiline = $true
$txtLog.ScrollBars = "Vertical"
$txtLog.ReadOnly = $true
$txtLog.BackColor = [System.Drawing.Color]::FromArgb(12, 14, 18)
$txtLog.ForeColor = [System.Drawing.Color]::FromArgb(0, 235, 145)
$txtLog.Font = New-Object System.Drawing.Font("Consolas", 9)
$txtLog.Text = "Ready. Lagyan ng check ang mga app sa kaliwa/gitna o pindutin ang site buttons sa kanan."
$form.Controls.Add($txtLog)

# Download Handler
$btnStart.Add_Click({
    $selected = @()
    foreach ($cb in $checkboxes) {
        if ($cb.Checked) { $selected += $cb.Tag }
    }
    $customId = $txtCustom.Text.Trim()
    if ($customId -ne "") {
        $selected += @{ Name = $customId; ID = $customId }
    }

    if ($selected.Count -eq 0) {
        [System.Windows.Forms.MessageBox]::Show("Pumili muna ng kahit isang app.", "Walang Napili", "OK", "Warning")
        return
    }

    $confirm = [System.Windows.Forms.MessageBox]::Show("Simulan ang download at install ng $($selected.Count) napiling app(s)?", "Confirm Download", "YesNo", "Question")
    if ($confirm -ne "Yes") { return }

    $btnStart.Enabled = $false
    $txtLog.Clear()

    foreach ($item in $selected) {
        $txtLog.AppendText("[*] Downloading & installing $($item.Name)...`r`n")
        [System.Windows.Forms.Application]::DoEvents()

        $proc = Start-Process -FilePath "winget" -ArgumentList "install --id=$($item.ID) --exact --silent --accept-package-agreements --accept-source-agreements" -Wait -PassThru -NoNewWindow
        if ($proc.ExitCode -eq 0) {
            $txtLog.AppendText("[OK] Matagumpay na na-install ang $($item.Name).`r`n")
        } else {
            $txtLog.AppendText("[FAIL] May error sa $($item.Name) (Code: $($proc.ExitCode)).`r`n")
        }
        [System.Windows.Forms.Application]::DoEvents()
    }

    [console]::beep(800, 200)
    [console]::beep(1000, 300)
    $txtLog.AppendText("=== TAPOS NA LAHAT NG INSTALLATION ===`r`n")
    $btnStart.Enabled = $true
    [System.Windows.Forms.MessageBox]::Show("Tapos na ang napiling downloads at installations!", "Completed", "OK", "Information")
})

[void]$form.ShowDialog()