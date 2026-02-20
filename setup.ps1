# ============================================
# Windows Post-Installation Script
# By: Absolutionwall
# ============================================

#Requires -RunAsAdministrator

# Configuración de colores
$Host.UI.RawUI.BackgroundColor = "Black"
$Host.UI.RawUI.ForegroundColor = "White"
Clear-Host

# ============================================
# SISTEMA DE LOGGING
# ============================================

$LogPath = Join-Path ([Environment]::GetFolderPath("MyDocuments")) "setup-log.txt"

function Write-Log {
    param(
        [string]$Message,
        [ValidateSet("INFO", "OK", "WARN", "ERROR", "SECTION")]
        [string]$Level = "INFO"
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $line = "[$timestamp] [$Level] $Message"
    Add-Content -Path $LogPath -Value $line -Encoding UTF8

    # Echo a consola solo en caso de WARN/ERROR para no duplicar salida visual
    switch ($Level) {
        "WARN"    { Write-Host "  ⚠ $Message" -ForegroundColor Yellow }
        "ERROR"   { Write-Host "  ✗ $Message" -ForegroundColor Red }
        "SECTION" { Write-Host "" }   # silencioso; la sección ya se imprime con Write-Host
    }
}

function Write-LogSeparator {
    param([string]$Title = "")
    $sep = "=" * 60
    $line = if ($Title) { "`r`n$sep`r`n  $Title`r`n$sep" } else { $sep }
    Add-Content -Path $LogPath -Value $line -Encoding UTF8
}

# Encabezado inicial del log
Write-LogSeparator "SETUP INICIADO  -  $(Get-Date -Format 'dddd dd/MM/yyyy HH:mm:ss')"
Write-Log "Usuario : $env:USERNAME" "INFO"
Write-Log "Equipo  : $env:COMPUTERNAME" "INFO"
Write-Log "Log     : $LogPath" "INFO"

# ============================================
# DEFINICIÓN DE PROGRAMAS
# ============================================

$AllPrograms = @{
    # Programas base
    "Chrome"         = @{ ID = "Google.Chrome";                    Name = "Google Chrome" }
    "Firefox"        = @{ ID = "Mozilla.Firefox";                  Name = "Mozilla Firefox" }
    "Brave"          = @{ ID = "Brave.Brave";                      Name = "Brave Browser" }
    "Edge"           = @{ ID = "Microsoft.Edge";                   Name = "Microsoft Edge" }

    # Multimedia
    "VLC"            = @{ ID = "VideoLAN.VLC";                     Name = "VLC Media Player" }
    "OBS"            = @{ ID = "OBSProject.OBSStudio";             Name = "OBS Studio" }
    "Audacity"       = @{ ID = "Audacity.Audacity";                Name = "Audacity" }
    "HandBrake"      = @{ ID = "HandBrake.HandBrake";              Name = "HandBrake" }

    # Gaming
    "Steam"          = @{ ID = "Valve.Steam";                      Name = "Steam" }

    # Utilidades
    "WinRAR"         = @{ ID = "RARLab.WinRAR";                    Name = "WinRAR" }
    "7Zip"           = @{ ID = "7zip.7zip";                        Name = "7-Zip" }
    "NotepadPlusPlus"= @{ ID = "Notepad++.Notepad++";              Name = "Notepad++" }
    "Everything"     = @{ ID = "voidtools.Everything";             Name = "Everything Search" }
    "qBittorrent"    = @{ ID = "qBittorrent.qBittorrent";          Name = "qBittorrent" }

    # Ofimática
    "LibreOffice"    = @{ ID = "TheDocumentFoundation.LibreOffice"; Name = "LibreOffice" }
    "Office"         = @{ ID = "Microsoft.Office";                 Name = "Microsoft Office" }

    # Herramientas
    "MSIAfterburner" = @{ ID = "Guru3D.Afterburner";               Name = "MSI Afterburner" }
    "HWiNFO"         = @{ ID = "REALiX.HWiNFO";                   Name = "HWiNFO" }
    "CoreTemp"       = @{ ID = "ALCPU.CoreTemp";                   Name = "Core Temp" }
    "Rainmeter"      = @{ ID = "Rainmeter.Rainmeter";              Name = "Rainmeter" }

    # Microsoft Store Apps
    "FDM"            = @{ ID = "9WZDNCRDH8Z7"; Name = "Free Download Manager"; Source = "msstore" }
    "FxSound"        = @{ ID = "9NBLGGH4PNM9"; Name = "FxSound";               Source = "msstore" }
    "Lively"         = @{ ID = "9NTM2QC6QWS7"; Name = "Lively Wallpaper";      Source = "msstore" }
    "RealtekAudio"   = @{ ID = "9P0PHKM0D8P8"; Name = "Realtek Audio Console"; Source = "msstore" }
}

# ============================================
# PERFILES PREDEFINIDOS
# ============================================

$Profiles = @{
    "WALLPC" = @(
        "Chrome", "Steam", "WinRAR", "MSIAfterburner", "NotepadPlusPlus",
        "Rainmeter", "CoreTemp", "OBS", "HWiNFO", "VLC",
        "FDM", "FxSound", "Lively"
    )
    "GALAPC" = @(
        "Chrome", "Steam", "WinRAR", "MSIAfterburner", "VLC",
        "FDM", "FxSound", "RealtekAudio"
    )
}

# ============================================
# TWEAKS DE WINDOWS
# ============================================

$WindowsTweaks = @{
    "ClassicContextMenu" = @{
        Name   = "Menú contextual clásico (Win11)"
        Action = {
            reg add "HKEY_CURRENT_USER\SOFTWARE\CLASSES\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32" /ve /f | Out-Null
        }
    }
    "DisableInactivityTimeout" = @{
        Name   = "Deshabilitar suspensión automática"
        Action = {
            reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v InactivityTimeoutSecs /t REG_DWORD /d 0 /f | Out-Null
            powercfg /SETACVALUEINDEX SCHEME_CURRENT SUB_SLEEP STANDBYIDLE 0 | Out-Null
            powercfg /SETDCVALUEINDEX SCHEME_CURRENT SUB_SLEEP STANDBYIDLE 0 | Out-Null
        }
    }
    "ScreenTimeout" = @{
        Name   = "Apagado de pantalla (5 minutos)"
        Action = {
            powercfg /SETACVALUEINDEX SCHEME_CURRENT SUB_VIDEO VIDEOIDLE 300 | Out-Null
            powercfg /SETDCVALUEINDEX SCHEME_CURRENT SUB_VIDEO VIDEOIDLE 300 | Out-Null
        }
    }
    "ShowFileExtensions" = @{
        Name   = "Mostrar extensiones de archivo"
        Action = {
            reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v HideFileExt /t REG_DWORD /d 0 /f | Out-Null
        }
    }
    "DarkMode" = @{
        Name   = "Activar modo oscuro"
        Action = {
            reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" /v AppsUseLightTheme /t REG_DWORD /d 0 /f | Out-Null
            reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" /v SystemUsesLightTheme /t REG_DWORD /d 0 /f | Out-Null
        }
    }
    "WindowsUpdate" = @{
        Name   = "Ejecutar Windows Update"
        Action = {
            Start-Process "ms-settings:windowsupdate" -WindowStyle Hidden
        }
    }
}

# ============================================
# FUNCIONES
# ============================================

function Show-Banner {
    Clear-Host
    Write-Host "╔════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║                                                        ║" -ForegroundColor Cyan
    Write-Host "║        WINDOWS POST-INSTALACIÓN SETUP                  ║" -ForegroundColor Cyan
    Write-Host "║        by absolutionwall                               ║" -ForegroundColor Cyan
    Write-Host "║                                                        ║" -ForegroundColor Cyan
    Write-Host "╚════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""
}

function Show-Menu {
    Show-Banner
    Write-Host "Selecciona una opción:" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  [1] Selección Manual de Programas" -ForegroundColor Green
    Write-Host "  [2] Registrar Tareas Programadas de Mantenimiento" -ForegroundColor Green
    Write-Host "  [0] Salir" -ForegroundColor Red
    Write-Host ""
    Write-Host ""
}

function Show-ProgramSelection {
    Show-Banner
    Write-Host "Selecciona los programas a instalar (separados por comas):" -ForegroundColor Yellow
    Write-Host ""

    $counter = 1
    $programList = @()

    Write-Host "═══ NAVEGADORES ═══" -ForegroundColor Cyan
    foreach ($key in @("Chrome", "Firefox", "Brave", "Edge")) {
        Write-Host "  [$counter] $($AllPrograms[$key].Name)" -ForegroundColor White
        $programList += $key
        $counter++
    }

    Write-Host "`n═══ MULTIMEDIA ═══" -ForegroundColor Cyan
    foreach ($key in @("VLC", "OBS", "Audacity", "HandBrake")) {
        Write-Host "  [$counter] $($AllPrograms[$key].Name)" -ForegroundColor White
        $programList += $key
        $counter++
    }

    Write-Host "`n═══ GAMING ═══" -ForegroundColor Cyan
    foreach ($key in @("Steam")) {
        Write-Host "  [$counter] $($AllPrograms[$key].Name)" -ForegroundColor White
        $programList += $key
        $counter++
    }

    Write-Host "`n═══ UTILIDADES ═══" -ForegroundColor Cyan
    foreach ($key in @("WinRAR", "7Zip", "NotepadPlusPlus", "Everything", "qBittorrent")) {
        Write-Host "  [$counter] $($AllPrograms[$key].Name)" -ForegroundColor White
        $programList += $key
        $counter++
    }

    Write-Host "`n═══ OFIMÁTICA ═══" -ForegroundColor Cyan
    foreach ($key in @("LibreOffice", "Office")) {
        Write-Host "  [$counter] $($AllPrograms[$key].Name)" -ForegroundColor White
        $programList += $key
        $counter++
    }

    Write-Host "`n═══ HERRAMIENTAS ═══" -ForegroundColor Cyan
    foreach ($key in @("MSIAfterburner", "HWiNFO", "CoreTemp", "Rainmeter")) {
        Write-Host "  [$counter] $($AllPrograms[$key].Name)" -ForegroundColor White
        $programList += $key
        $counter++
    }

    Write-Host "`n═══ MICROSOFT STORE ═══" -ForegroundColor Cyan
    foreach ($key in @("FDM", "FxSound", "Lively", "RealtekAudio")) {
        Write-Host "  [$counter] $($AllPrograms[$key].Name)" -ForegroundColor White
        $programList += $key
        $counter++
    }

    Write-Host "`n═══ TWEAKS DE WINDOWS ═══" -ForegroundColor Magenta
    $tweakCounter = 100
    $tweakList = @()
    foreach ($key in $WindowsTweaks.Keys) {
        Write-Host "  [$tweakCounter] $($WindowsTweaks[$key].Name)" -ForegroundColor White
        $tweakList += $key
        $tweakCounter++
    }

    Write-Host ""
    Write-Host "Ingresa los números separados por comas (ej: 1,3,5,100,101)" -ForegroundColor Yellow
    Write-Host "O escribe 'TODO' para seleccionar todos los programas" -ForegroundColor Yellow
    Write-Host "Escribe '0' para volver" -ForegroundColor Red
    Write-Host ""

    $selection = Read-Host "Selección"

    if ($selection -eq "0") {
        return $null
    }

    $selectedPrograms = @()
    $selectedTweaks = @()

    if ($selection.ToUpper() -eq "TODO") {
        $selectedPrograms = $programList
        $selectedTweaks = $tweakList
    } else {
        $numbers = $selection -split ',' | ForEach-Object { $_.Trim() }
        foreach ($num in $numbers) {
            if ($num -match '^\d+$') {
                $index = [int]$num
                if ($index -ge 1 -and $index -le $programList.Count) {
                    $selectedPrograms += $programList[$index - 1]
                } elseif ($index -ge 100 -and $index -lt (100 + $tweakList.Count)) {
                    $selectedTweaks += $tweakList[$index - 100]
                }
            }
        }
    }

    return @{
        Programs = $selectedPrograms
        Tweaks   = $selectedTweaks
    }
}

function Show-Confirmation {
    param(
        [array]$Programs,
        [array]$Tweaks,
        [string]$ProfileName = ""
    )

    Show-Banner

    if ($ProfileName) {
        Write-Host "═══ PERFIL: $ProfileName ═══" -ForegroundColor Magenta
        Write-Host ""
    }

    Write-Host "Se instalarán los siguientes programas:" -ForegroundColor Yellow
    Write-Host ""

    foreach ($prog in $Programs) {
        if ($AllPrograms.ContainsKey($prog)) {
            Write-Host "  ✓ $($AllPrograms[$prog].Name)" -ForegroundColor Green
        }
    }

    if ($Tweaks.Count -gt 0) {
        Write-Host "`nSe aplicarán los siguientes tweaks:" -ForegroundColor Yellow
        Write-Host ""
        foreach ($tweak in $Tweaks) {
            if ($WindowsTweaks.ContainsKey($tweak)) {
                Write-Host "  ✓ $($WindowsTweaks[$tweak].Name)" -ForegroundColor Cyan
            }
        }
    }

    Write-Host ""
    $confirm = Read-Host "¿Confirmar instalación? (S/N)"

    return ($confirm.ToUpper() -eq "S")
}

function Install-RainmeterConfig {
    $repoBase          = "https://raw.githubusercontent.com/absolutionwall/win-setup/main"
    $rainmeterConfigUrl = "$repoBase/configs/rainmeter/Rainmeter.rar"
    $documentsPath     = [Environment]::GetFolderPath("MyDocuments")
    $rainmeterPath     = Join-Path $documentsPath "Rainmeter"
    $tempRarPath       = Join-Path $env:TEMP "Rainmeter.rar"

    try {
        Write-Host "      → Descargando configuración..." -ForegroundColor Gray
        Write-Log "Rainmeter: descargando config desde $rainmeterConfigUrl" "INFO"
        Invoke-WebRequest -Uri $rainmeterConfigUrl -OutFile $tempRarPath -ErrorAction Stop

        $winrarPath = "C:\Program Files\WinRAR\WinRAR.exe"
        if (Test-Path $winrarPath) {
            if (!(Test-Path $rainmeterPath)) {
                New-Item -ItemType Directory -Path $rainmeterPath -Force | Out-Null
            }
            Write-Host "      → Extrayendo en Mis Documentos..." -ForegroundColor Gray
            Start-Process -FilePath $winrarPath -ArgumentList "x -o+ `"$tempRarPath`" `"$rainmeterPath\`"" -Wait -NoNewWindow
            Remove-Item $tempRarPath -Force
            Write-Host "    ✓ Configuración de Rainmeter instalada en: $rainmeterPath" -ForegroundColor Green
            Write-Log "Rainmeter: config instalada en $rainmeterPath" "OK"
        } else {
            Write-Host "    ⚠ WinRAR no encontrado. Descarga manual en: $tempRarPath" -ForegroundColor Yellow
            Write-Log "Rainmeter: WinRAR no encontrado, config queda en $tempRarPath" "WARN"
        }
    } catch {
        Write-Host "    ✗ Error descargando configuración de Rainmeter: $($_.Exception.Message)" -ForegroundColor Red
        Write-Log "Rainmeter: error descargando config - $($_.Exception.Message)" "ERROR"
    }
}

function Install-Programs {
    param(
        [array]$Programs,
        [array]$Tweaks
    )

    Show-Banner
    Write-Host "═══ INICIANDO INSTALACIÓN ═══" -ForegroundColor Green
    Write-Host ""
    Write-LogSeparator "INSTALACIÓN DE PROGRAMAS"

    # Verificar Winget
    if (!(Get-Command winget -ErrorAction SilentlyContinue)) {
        Write-Host "ERROR: Winget no está instalado." -ForegroundColor Red
        Write-Host "Instala 'App Installer' desde Microsoft Store." -ForegroundColor Yellow
        Write-Log "Winget no encontrado. Abortando instalación." "ERROR"
        pause
        return
    }
    Write-Log "Winget encontrado. Versión: $(winget --version)" "INFO"

    $total   = $Programs.Count
    $current = 0

    foreach ($prog in $Programs) {
        $current++
        if ($AllPrograms.ContainsKey($prog)) {
            $app    = $AllPrograms[$prog]
            $source = if ($app.Source -eq "msstore") { "msstore" } else { "winget" }

            Write-Host "[$current/$total] Instalando: $($app.Name)..." -ForegroundColor Cyan
            Write-Log "[$current/$total] Instalando $($app.Name) (ID: $($app.ID), source: $source)" "INFO"

            winget install --id=$($app.ID) --source=$source --silent --accept-package-agreements --accept-source-agreements | Out-Null

            if ($LASTEXITCODE -eq 0) {
                Write-Host "  ✓ $($app.Name) instalado correctamente" -ForegroundColor Green
                Write-Log "$($app.Name): instalado OK" "OK"

                if ($prog -eq "Rainmeter") {
                    Write-Host "    → Descargando configuración de Rainmeter..." -ForegroundColor Yellow
                    Install-RainmeterConfig
                }
            } else {
                Write-Host "  ✗ Error instalando $($app.Name)" -ForegroundColor Red
                Write-Log "$($app.Name): error en instalación (exit code: $LASTEXITCODE)" "ERROR"
            }
        }
    }

    # Aplicar tweaks
    if ($Tweaks.Count -gt 0) {
        Write-Host "`n═══ APLICANDO TWEAKS ═══" -ForegroundColor Magenta
        Write-Host ""
        Write-LogSeparator "TWEAKS DE WINDOWS"

        foreach ($tweak in $Tweaks) {
            if ($WindowsTweaks.ContainsKey($tweak)) {
                Write-Host "  → $($WindowsTweaks[$tweak].Name)..." -ForegroundColor Cyan
                Write-Log "Aplicando tweak: $($WindowsTweaks[$tweak].Name)" "INFO"
                try {
                    & $WindowsTweaks[$tweak].Action
                    Write-Host "  ✓ Aplicado" -ForegroundColor Green
                    Write-Log "Tweak OK: $($WindowsTweaks[$tweak].Name)" "OK"
                } catch {
                    Write-Log "Tweak FALLIDO: $($WindowsTweaks[$tweak].Name) - $($_.Exception.Message)" "ERROR"
                }
            }
        }
    }

    Write-Host "`n═══ INSTALACIÓN COMPLETADA ═══" -ForegroundColor Green
    Write-Log "Instalación finalizada." "INFO"
    Write-Host ""
}

function Install-ProfileSpecific {
    param([string]$ProfileName)

    $repoBase = "https://raw.githubusercontent.com/absolutionwall/win-setup/main"

    Show-Banner
    Write-Host "═══ CONFIGURACIONES ADICIONALES ═══" -ForegroundColor Magenta
    Write-Host ""
    Write-LogSeparator "CONFIGURACIONES ADICIONALES - PERFIL $ProfileName"

    # Copiar archivos de configuración NVIDIA
    Write-Host "→ Configurando archivos NVIDIA..." -ForegroundColor Cyan
    Write-Log "NVIDIA: copiando archivos de configuración" "INFO"
    $nvidiaPath = "C:\ProgramData\NVIDIA Corporation\Drs"
    if (Test-Path $nvidiaPath) {
        try {
            Invoke-WebRequest "$repoBase/configs/nvidia/nvdrsdb0.bin" -OutFile "$nvidiaPath\nvdrsdb0.bin"
            Invoke-WebRequest "$repoBase/configs/nvidia/nvdrsdb1.bin" -OutFile "$nvidiaPath\nvdrsdb1.bin"
            Write-Host "  ✓ Archivos NVIDIA copiados" -ForegroundColor Green
            Write-Log "NVIDIA: archivos copiados OK" "OK"
        } catch {
            Write-Host "  ✗ Error copiando archivos NVIDIA" -ForegroundColor Red
            Write-Log "NVIDIA: error copiando archivos - $($_.Exception.Message)" "ERROR"
        }
    } else {
        Write-Log "NVIDIA: carpeta $nvidiaPath no encontrada, se omite" "WARN"
    }

    # Copiar licencia WinRAR
    Write-Host "→ Configurando licencia WinRAR..." -ForegroundColor Cyan
    Write-Log "WinRAR: instalando licencia" "INFO"
    $winrarPath = "C:\Program Files\WinRAR"
    if (Test-Path $winrarPath) {
        try {
            Invoke-WebRequest "$repoBase/configs/winrar/rarreg.key" -OutFile "$winrarPath\rarreg.key"
            Write-Host "  ✓ Licencia WinRAR instalada" -ForegroundColor Green
            Write-Log "WinRAR: licencia instalada OK" "OK"
        } catch {
            Write-Host "  ✗ Error copiando licencia WinRAR" -ForegroundColor Red
            Write-Log "WinRAR: error copiando licencia - $($_.Exception.Message)" "ERROR"
        }
    } else {
        Write-Log "WinRAR: carpeta no encontrada, se omite licencia" "WARN"
    }

    # Instalar Twitch Drops Miner
    Write-Host "→ Instalando Twitch Drops Miner..." -ForegroundColor Cyan
    Write-Log "Twitch Drops Miner: descargando instalador" "INFO"
    try {
        $twitchPath = "$env:TEMP\TwitchDropsMiner.exe"
        Invoke-WebRequest "$repoBase/installers/Twitch%20Drops%20Miner.exe" -OutFile $twitchPath
        Start-Process $twitchPath -ArgumentList "/VERYSILENT" -Wait
        Write-Host "  ✓ Twitch Drops Miner instalado" -ForegroundColor Green
        Write-Log "Twitch Drops Miner: instalado OK" "OK"
    } catch {
        Write-Host "  ✗ Error instalando Twitch Drops Miner" -ForegroundColor Red
        Write-Log "Twitch Drops Miner: error - $($_.Exception.Message)" "ERROR"
    }

    # Driver NVIDIA Game Ready
    Write-Host "→ Descargando Driver NVIDIA Game Ready..." -ForegroundColor Cyan
    Write-Host "  ℹ Abre GeForce Experience o descarga desde nvidia.com" -ForegroundColor Yellow
    Write-Log "NVIDIA Driver: recordatorio mostrado al usuario" "INFO"

    # Drivers ASUS B550
    Write-Host "→ Drivers ASUS Prime B550..." -ForegroundColor Cyan
    Write-Host "  ℹ Abriendo página de descarga de ASUS..." -ForegroundColor Yellow
    Write-Log "ASUS B550: abriendo página de drivers" "INFO"
    Start-Process "https://www.asus.com/motherboards-components/motherboards/prime/prime-b550m-a-wifi-ii/helpdesk_download/"

    # Chrome como predeterminado
    Write-Host "→ Estableciendo Chrome como predeterminado..." -ForegroundColor Cyan
    Write-Log "Chrome: abriendo configuración de apps predeterminadas" "INFO"
    Start-Process "ms-settings:defaultapps"

    Write-Host "`n✓ Configuraciones completadas" -ForegroundColor Green
    Write-Log "Configuraciones adicionales del perfil $ProfileName completadas." "INFO"
    Write-Host ""
}

# ============================================
# TAREAS PROGRAMADAS - Mantenimiento semanal
# ============================================

function Register-MaintenanceTasks {
    param([switch]$Silent)
    Show-Banner
    Write-Host "═══ REGISTRANDO TAREAS DE MANTENIMIENTO ═══" -ForegroundColor Magenta
    Write-Host ""
    Write-LogSeparator "REGISTRO DE TAREAS PROGRAMADAS"

    # ------------------------------------------------------------------
    # 1. Disk Cleanup - cleanmgr /sagerun:1  (lunes 14:00)
    # ------------------------------------------------------------------
    $taskName_DC  = "Mantenimiento - Disk Cleanup Semanal"
    $taskDescr_DC = "Ejecuta cleanmgr con el perfil sageset:1. Limpia archivos temporales, papelera, cache de Internet, Delivery Optimization, minidumps, Windows Defender, Update Cleanup y otras categorias seleccionadas."

    Write-Host "  → Registrando: $taskName_DC..." -ForegroundColor Cyan
    Write-Log "Registrando tarea: $taskName_DC" "INFO"
    try {
        $action_DC   = New-ScheduledTaskAction -Execute "cleanmgr.exe" -Argument "/sagerun:1"
        $trigger_DC  = New-ScheduledTaskTrigger -Weekly -DaysOfWeek Monday -At "14:00"
        $settings_DC = New-ScheduledTaskSettingsSet `
            -ExecutionTimeLimit (New-TimeSpan -Hours 2) `
            -RunOnlyIfIdle:$false `
            -StartWhenAvailable `
            -WakeToRun:$false

        Register-ScheduledTask `
            -TaskName    $taskName_DC `
            -Description $taskDescr_DC `
            -Action      $action_DC `
            -Trigger     $trigger_DC `
            -Settings    $settings_DC `
            -RunLevel    Highest `
            -Force | Out-Null

        Write-Host "  ✓ Tarea registrada: $taskName_DC" -ForegroundColor Green
        Write-Log "Tarea registrada OK: $taskName_DC (lunes 14:00)" "OK"
    } catch {
        Write-Host "  ✗ Error registrando tarea Disk Cleanup" -ForegroundColor Red
        Write-Log "Error registrando tarea Disk Cleanup: $($_.Exception.Message)" "ERROR"
    }

    # ------------------------------------------------------------------
    # 2. Winget Update  (lunes 14:30)
    # ------------------------------------------------------------------
    $taskName_WG  = "Mantenimiento - Winget Update Semanal"
    $taskDescr_WG = "Actualiza todas las aplicaciones instaladas via winget. Registra la actividad en D:\winget-log.txt."

    $scriptDir  = "C:\Scripts\Maintenance"
    $scriptPath = "$scriptDir\Update-WingetApps.ps1"

    Write-Host "  → Creando script de actualización en $scriptPath..." -ForegroundColor Cyan
    Write-Log "Creando script de winget update en $scriptPath" "INFO"
    try {
        if (-not (Test-Path $scriptDir)) {
            New-Item -ItemType Directory -Path $scriptDir -Force | Out-Null
            Write-Log "Carpeta creada: $scriptDir" "OK"
        }

        $scriptContent = @'
# Actualizar todas las aplicaciones instaladas con winget
winget upgrade --all --include-unknown --silent --accept-package-agreements --accept-source-agreements

# Registro de la actualizacion
$date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
Add-Content -Path "D:\winget-log.txt" -Value "Actualizacion ejecutada: $date"
'@
        Set-Content -Path $scriptPath -Value $scriptContent -Encoding UTF8
        Write-Log "Script guardado OK: $scriptPath" "OK"
    } catch {
        Write-Log "Error creando script winget: $($_.Exception.Message)" "ERROR"
    }

    Write-Host "  → Registrando: $taskName_WG..." -ForegroundColor Cyan
    Write-Log "Registrando tarea: $taskName_WG" "INFO"
    try {
        $action_WG   = New-ScheduledTaskAction `
            -Execute  "powershell.exe" `
            -Argument "-NonInteractive -WindowStyle Hidden -ExecutionPolicy Bypass -File `"$scriptPath`""
        $trigger_WG  = New-ScheduledTaskTrigger -Weekly -DaysOfWeek Monday -At "14:30"
        $settings_WG = New-ScheduledTaskSettingsSet `
            -ExecutionTimeLimit (New-TimeSpan -Hours 1) `
            -RunOnlyIfIdle:$false `
            -StartWhenAvailable `
            -WakeToRun:$false

        Register-ScheduledTask `
            -TaskName    $taskName_WG `
            -Description $taskDescr_WG `
            -Action      $action_WG `
            -Trigger     $trigger_WG `
            -Settings    $settings_WG `
            -RunLevel    Highest `
            -Force | Out-Null

        Write-Host "  ✓ Tarea registrada: $taskName_WG" -ForegroundColor Green
        Write-Log "Tarea registrada OK: $taskName_WG (lunes 14:30)" "OK"
    } catch {
        Write-Host "  ✗ Error registrando tarea Winget Update" -ForegroundColor Red
        Write-Log "Error registrando tarea Winget Update: $($_.Exception.Message)" "ERROR"
    }

    Write-Host ""
    Write-Host "  ✓ Tareas de mantenimiento configuradas." -ForegroundColor Green
    Write-Host "    Log de winget : D:\winget-log.txt" -ForegroundColor Gray
    Write-Host "    Log de setup  : $LogPath" -ForegroundColor Gray
    Write-Host ""
    Write-Log "Registro de tareas de mantenimiento finalizado." "INFO"

    if (-not $Silent) {
        Write-Host "Presiona cualquier tecla para continuar..." -ForegroundColor Yellow
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    }
}

# ============================================
# LOOP PRINCIPAL
# ============================================

do {
    Show-Menu
    $option = Read-Host "Opción"

    # Comandos ocultos de perfil
    if ($option.ToUpper() -eq "WALLPC" -or $option.ToUpper() -eq "GALAPC") {
        $profileName      = $option.ToUpper()
        $selectedPrograms = $Profiles[$profileName]

        $selectedTweaks = @(
            "ClassicContextMenu",
            "DisableInactivityTimeout",
            "ScreenTimeout",
            "ShowFileExtensions",
            "DarkMode"
        )

        Write-LogSeparator "PERFIL SELECCIONADO: $profileName"
        Write-Log "Perfil: $profileName | Programas: $($selectedPrograms -join ', ')" "INFO"

        if (Show-Confirmation -Programs $selectedPrograms -Tweaks $selectedTweaks -ProfileName $profileName) {
            Install-Programs -Programs $selectedPrograms -Tweaks $selectedTweaks
            Install-ProfileSpecific -ProfileName $profileName
            Register-MaintenanceTasks -Silent
        } else {
            Write-Log "Instalación cancelada por el usuario (perfil $profileName)" "INFO"
        }

        Write-Host "`nPresiona cualquier tecla para continuar..." -ForegroundColor Yellow
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        continue
    }

    switch ($option) {
        '1' {
            $selection = Show-ProgramSelection
            if ($selection) {
                Write-Log "Selección manual | Programas: $($selection.Programs -join ', ') | Tweaks: $($selection.Tweaks -join ', ')" "INFO"
                if (Show-Confirmation -Programs $selection.Programs -Tweaks $selection.Tweaks) {
                    Install-Programs -Programs $selection.Programs -Tweaks $selection.Tweaks
                } else {
                    Write-Log "Instalación cancelada por el usuario (selección manual)" "INFO"
                }
                Write-Host "`nPresiona cualquier tecla para continuar..." -ForegroundColor Yellow
                $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
            }
        }
        '2' {
            Register-MaintenanceTasks
        }
        '0' {
            Write-Log "Script finalizado por el usuario." "INFO"
            Write-LogSeparator "FIN DE SESIÓN  -  $(Get-Date -Format 'dddd dd/MM/yyyy HH:mm:ss')"
            Write-Host "`n¡Hasta luego!" -ForegroundColor Cyan
            exit
        }
        default {
            Write-Host "`nOpción inválida." -ForegroundColor Red
            Write-Log "Opción inválida ingresada: '$option'" "WARN"
            Start-Sleep -Seconds 1
        }
    }

} while ($true)
