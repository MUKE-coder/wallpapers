#!/usr/bin/env pwsh
# Wallpapers installer (Windows)
# Usage: irm https://raw.githubusercontent.com/MUKE-coder/wallpapers/main/install.ps1 | iex

$ErrorActionPreference = 'Stop'

$Repo     = 'MUKE-coder/wallpapers'
$Branch   = 'main'
$Dest     = Join-Path $env:USERPROFILE 'Pictures\wallpapers'
$Interval = 5  # minutes between rotations
$TaskName = 'WallpaperRotation'

Write-Host "==> Installing wallpapers to $Dest" -ForegroundColor Cyan
New-Item -ItemType Directory -Force -Path $Dest | Out-Null

# Download repo zip
$ZipUrl   = "https://github.com/$Repo/archive/refs/heads/$Branch.zip"
$TmpZip   = Join-Path $env:TEMP 'wallpapers.zip'
$ExtractRoot = Join-Path $env:TEMP "wallpapers-extract-$([guid]::NewGuid())"

Write-Host "==> Downloading $ZipUrl"
Invoke-WebRequest -Uri $ZipUrl -OutFile $TmpZip -UseBasicParsing
Expand-Archive -Path $TmpZip -DestinationPath $ExtractRoot -Force

$Src = Join-Path $ExtractRoot "wallpapers-$Branch"
$Images = Get-ChildItem -Path $Src -File | Where-Object { $_.Extension -match '^\.(jpe?g|png)$' }
$Images | Copy-Item -Destination $Dest -Force

Remove-Item $TmpZip -Force
Remove-Item $ExtractRoot -Recurse -Force

Write-Host "==> Installed $($Images.Count) wallpapers" -ForegroundColor Green

# Write rotation script next to the images
$RotateScript = Join-Path $Dest 'rotate-wallpaper.ps1'
@'
$ErrorActionPreference = 'SilentlyContinue'
$Folder = Join-Path $env:USERPROFILE 'Pictures\wallpapers'
$Pick = Get-ChildItem -Path $Folder -File |
    Where-Object { $_.Extension -match '^\.(jpe?g|png)$' } |
    Get-Random
if (-not $Pick) { exit }

Add-Type -TypeDefinition @"
using System.Runtime.InteropServices;
public class Wp {
    [DllImport("user32.dll", CharSet=CharSet.Auto)]
    public static extern int SystemParametersInfo(int uAction, int uParam, string lpvParam, int fuWinIni);
}
"@ -ErrorAction SilentlyContinue
[Wp]::SystemParametersInfo(20, 0, $Pick.FullName, 3) | Out-Null
'@ | Set-Content -Path $RotateScript -Encoding UTF8

# Apply first wallpaper immediately
& powershell -NoProfile -ExecutionPolicy Bypass -File $RotateScript

# Register the scheduled task (recreate cleanly)
Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false -ErrorAction SilentlyContinue

$Action = New-ScheduledTaskAction `
    -Execute 'powershell.exe' `
    -Argument "-NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File `"$RotateScript`""

$Trigger = New-ScheduledTaskTrigger `
    -Once -At (Get-Date).AddMinutes(1) `
    -RepetitionInterval (New-TimeSpan -Minutes $Interval)

$Settings = New-ScheduledTaskSettingsSet `
    -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries `
    -StartWhenAvailable

Register-ScheduledTask -TaskName $TaskName `
    -Action $Action -Trigger $Trigger -Settings $Settings `
    -Description 'Rotate desktop wallpaper from ~/Pictures/wallpapers' | Out-Null

Write-Host "==> Rotating every $Interval minutes (task: $TaskName)" -ForegroundColor Green
Write-Host "    Uninstall: Unregister-ScheduledTask -TaskName $TaskName -Confirm:`$false"
