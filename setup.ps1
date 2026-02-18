# ============================================
# Windows Post-Installation Script
# By: absolutionwall
# ============================================

#Requires -RunAsAdministrator

# Configuración de colores
$Host.UI.RawUI.BackgroundColor = "Black"
$Host.UI.RawUI.ForegroundColor = "White"
Clear-Host

# ============================================
# DEFINICIÓN DE PROGRAMAS
# ============================================

$AllPrograms = @{
    # Programas base
    "Chrome" = @{ ID = "Google.Chrome"; Name = "Google Chrome" }
    "Firefox" = @{ ID = "Mozilla.Firefox"; Name = "Mozilla Firefox" }
    "Brave" = @{ ID = "Brave.Brave"; Name = "Brave Browser" }
    "Edge" = @{ ID = "Microsoft.Edge"; Name = "Microsoft Edge" }
    
    # Multimedia
    "VLC" = @{ ID = "VideoLAN.VLC"; Name = "VLC Media Player" }
    "OBS" = @{ ID = "OBSProject.OBSStudio"; Name = "OBS Studio" }
    "Audacity" = @{ ID = "Audacity.Audacity"; Name = "Audacity" }
    "HandBrake" = @{ ID = "HandBrake.HandBrake"; Name = "HandBrake" }
    
    # Gaming
    "Steam" = @{ ID = "Valve.Steam"; Name = "Steam" }
    
    # Utilidades
    "WinRAR" = @{ ID = "RARLab.WinRAR"; Name = "WinRAR" }
    "7Zip" = @{ ID = "7zip.7zip"; Name = "7-Zip" }
    "NotepadPlusPlus" = @{ ID = "Notepad++.Notepad++"; Name = "Notepad++" }
    "Everything" = @{ ID = "voidtools.Everything"; Name = "Everything Search" }
    "qBittorrent" = @{ ID = "qBittorrent.qBittorrent"; Name = "qBittorrent" }
    
    # Ofimática
    "LibreOffice" = @{ ID = "TheDocumentFoundation.LibreOffice"; Name = "LibreOffice" }
    "Office" = @{ ID = "Microsoft.Office"; Name = "Microsoft Office" }
    
    # Herramientas
    "MSIAfterburner" = @{ ID = "Guru3D.Afterburner"; Name = "MSI Afterburner" }
    "HWiNFO" = @{ ID = "REALiX.HWiNFO"; Name = "HWiNFO" }
    "CoreTemp" = @{ ID = "ALCPU.CoreTemp"; Name = "Core Temp" }
    "Rainmeter" = @{ ID = "Rainmeter.Rainmeter"; Name = "Rainmeter" }
    
    # Microsoft Store Apps
    "FDM" = @{ ID = "9WZDNCRDH8Z7"; Name = "Free Download Manager"; Source = "msstore" }
    "FxSound" = @{ ID = "9NBLGGH4PNM9"; Name = "FxSound"; Source = "msstore" }
    "Lively" = @{ ID = "9NTM2QC6QWS7"; Name = "Lively Wallpaper"; Source = "msstore" }
    "RealtekAudio" = @{ ID = "9P0PHKM0D8P8"; Name = "Realtek Audio Console"; Source = "msstore" }
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
        Name = "Menú contextual clásico (Win11)"
        Action = {
            reg add "HKEY_CURRENT_USER\SOFTWARE\CLASSES\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32" /ve /f | Out-Null
        }
    }
    "DisableInactivityTimeout" = @{
        Name = "Deshabilitar suspensión automática"
        Action = {
            reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v InactivityTimeoutSecs /t REG_DWORD /d 0 /f | Out-Null
            powercfg /SETACVALUEINDEX SCHEME_CURRENT SUB_SLEEP STANDBYIDLE 0 | Out-Null
            powercfg /SETDCVALUEINDEX SCHEME_CURRENT SUB_SLEEP STANDBYIDLE 0 | Out-Null
        }
    }
    "ScreenTimeout" = @{
        Name = "Apagado de pantalla (5 minutos)"
        Action = {
            powercfg /SETACVALUEINDEX SCHEME_CURRENT SUB_VIDEO VIDEOIDLE 300 | Out-Null
            powercfg /SETDCVALUEINDEX SCHEME_CURRENT SUB_VIDEO VIDEOIDLE 300 | Out-Null
        }
    }
    "ShowFileExtensions" = @{
        Name = "Mostrar extensiones de archivo"
        Action = {
            reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v HideFileExt /t REG_DWORD /d 0 /f | Out-Null
        }
    }
    "DarkMode" = @{
        Name = "Activar modo oscuro"
        Action = {
            reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" /v AppsUseLightTheme /t REG_DWORD /d 0 /f | Out-Null
            reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" /v SystemUsesLightTheme /t REG_DWORD /d 0 /f | Out-Null
        }
    }
    "WindowsUpdate" = @{
        Name = "Ejecutar Windows Update"
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
    Write-Host "  [0] Salir" -ForegroundColor Red
    Write-Host ""
    Write-Host "Comandos ocultos: WALLPC, GALAPC" -ForegroundColor DarkGray
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
        Tweaks = $selectedTweaks
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

function Install-Programs {
    param(
        [array]$Programs,
        [array]$Tweaks
    )
    
    Show-Banner
    Write-Host "═══ INICIANDO INSTALACIÓN ═══" -ForegroundColor Green
    Write-Host ""
    
    # Verificar Winget
    if (!(Get-Command winget -ErrorAction SilentlyContinue)) {
        Write-Host "ERROR: Winget no está instalado." -ForegroundColor Red
        Write-Host "Instala 'App Installer' desde Microsoft Store." -ForegroundColor Yellow
        pause
        return
    }
    
    # Instalar programas
    $total = $Programs.Count
    $current = 0
    
    foreach ($prog in $Programs) {
        $current++
        if ($AllPrograms.ContainsKey($prog)) {
            $app = $AllPrograms[$prog]
            Write-Host "[$current/$total] Instalando: $($app.Name)..." -ForegroundColor Cyan
            
            $source = if ($app.Source -eq "msstore") { "msstore" } else { "winget" }
            
            winget install --id=$($app.ID) --source=$source --silent --accept-package-agreements --accept-source-agreements | Out-Null
            
            if ($LASTEXITCODE -eq 0) {
                Write-Host "  ✓ $($app.Name) instalado correctamente" -ForegroundColor Green
            } else {
                Write-Host "  ✗ Error instalando $($app.Name)" -ForegroundColor Red
            }
        }
    }
    
    # Aplicar tweaks
    if ($Tweaks.Count -gt 0) {
        Write-Host "`n═══ APLICANDO TWEAKS ═══" -ForegroundColor Magenta
        Write-Host ""
        
        foreach ($tweak in $Tweaks) {
            if ($WindowsTweaks.ContainsKey($tweak)) {
                Write-Host "  → $($WindowsTweaks[$tweak].Name)..." -ForegroundColor Cyan
                & $WindowsTweaks[$tweak].Action
                Write-Host "  ✓ Aplicado" -ForegroundColor Green
            }
        }
    }
    
    Write-Host "`n═══ INSTALACIÓN COMPLETADA ═══" -ForegroundColor Green
    Write-Host ""
}

function Install-ProfileSpecific {
    param([string]$ProfileName)
    
    # Configuraciones adicionales específicas del perfil
    $repoBase = "https://raw.githubusercontent.com/absolutionwall/win-setup/main"
    
    Show-Banner
    Write-Host "═══ CONFIGURACIONES ADICIONALES ═══" -ForegroundColor Magenta
    Write-Host ""
    
    # Copiar archivos de configuración NVIDIA
    Write-Host "→ Configurando archivos NVIDIA..." -ForegroundColor Cyan
    $nvidiaPath = "C:\ProgramData\NVIDIA Corporation\Drs"
    if (Test-Path $nvidiaPath) {
        try {
            Invoke-WebRequest "$repoBase/configs/nvidia/nvdrsdb0.bin" -OutFile "$nvidiaPath\nvdrsdb0.bin"
            Invoke-WebRequest "$repoBase/configs/nvidia/nvdrsdb1.bin" -OutFile "$nvidiaPath\nvdrsdb1.bin"
            Write-Host "  ✓ Archivos NVIDIA copiados" -ForegroundColor Green
        } catch {
            Write-Host "  ✗ Error copiando archivos NVIDIA" -ForegroundColor Red
        }
    }
    
    # Copiar licencia WinRAR
    Write-Host "→ Configurando licencia WinRAR..." -ForegroundColor Cyan
    $winrarPath = "C:\Program Files\WinRAR"
    if (Test-Path $winrarPath) {
        try {
            Invoke-WebRequest "$repoBase/configs/winrar/rarreg.key" -OutFile "$winrarPath\rarreg.key"
            Write-Host "  ✓ Licencia WinRAR instalada" -ForegroundColor Green
        } catch {
            Write-Host "  ✗ Error copiando licencia WinRAR" -ForegroundColor Red
        }
    }
    
    # Instalar Twitch Drops Miner
    Write-Host "→ Instalando Twitch Drops Miner..." -ForegroundColor Cyan
    try {
        $twitchPath = "$env:TEMP\TwitchDropsMiner.exe"
        Invoke-WebRequest "$repoBase/installers/Twitch%20Drops%20Miner.exe" -OutFile $twitchPath
        Start-Process $twitchPath -ArgumentList "/VERYSILENT" -Wait
        Write-Host "  ✓ Twitch Drops Miner instalado" -ForegroundColor Green
    } catch {
        Write-Host "  ✗ Error instalando Twitch Drops Miner" -ForegroundColor Red
    }
    
    # Driver NVIDIA Game Ready
    Write-Host "→ Descargando Driver NVIDIA Game Ready..." -ForegroundColor Cyan
    Write-Host "  ℹ Abre GeForce Experience o descarga desde nvidia.com" -ForegroundColor Yellow
    
    # Drivers ASUS B550
    Write-Host "→ Drivers ASUS Prime B550..." -ForegroundColor Cyan
    Write-Host "  ℹ Abriendo página de descarga de ASUS..." -ForegroundColor Yellow
    Start-Process "https://www.asus.com/motherboards-components/motherboards/prime/prime-b550m-a-wifi-ii/helpdesk_download/"
    
    # Chrome como predeterminado
    Write-Host "→ Estableciendo Chrome como predeterminado..." -ForegroundColor Cyan
    Start-Process "ms-settings:defaultapps"
    
    Write-Host "`n✓ Configuraciones completadas" -ForegroundColor Green
    Write-Host ""
}

# ============================================
# LOOP PRINCIPAL
# ============================================

do {
    Show-Menu
    $option = Read-Host "Opción"
    
    # Comandos ocultos
    if ($option.ToUpper() -eq "WALLPC" -or $option.ToUpper() -eq "GALAPC") {
        $profileName = $option.ToUpper()
        $selectedPrograms = $Profiles[$profileName]
        
        # Agregar tweaks predeterminados del perfil
        $selectedTweaks = @(
            "ClassicContextMenu",
            "DisableInactivityTimeout", 
            "ScreenTimeout",
            "ShowFileExtensions",
            "DarkMode"
        )
        
        if (Show-Confirmation -Programs $selectedPrograms -Tweaks $selectedTweaks -ProfileName $profileName) {
            Install-Programs -Programs $selectedPrograms -Tweaks $selectedTweaks
            Install-ProfileSpecific -ProfileName $profileName
        }
        
        Write-Host "`nPresiona cualquier tecla para continuar..." -ForegroundColor Yellow
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        continue
    }
    
    switch ($option) {
        '1' {
            $selection = Show-ProgramSelection
            if ($selection) {
                if (Show-Confirmation -Programs $selection.Programs -Tweaks $selection.Tweaks) {
                    Install-Programs -Programs $selection.Programs -Tweaks $selection.Tweaks
                }
                
                Write-Host "`nPresiona cualquier tecla para continuar..." -ForegroundColor Yellow
                $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
            }
        }
        '0' {
            Write-Host "`n¡Hasta luego!" -ForegroundColor Cyan
            exit
        }
        default {
            Write-Host "`nOpción inválida." -ForegroundColor Red
            Start-Sleep -Seconds 1
        }
    }
    
} while ($true)
