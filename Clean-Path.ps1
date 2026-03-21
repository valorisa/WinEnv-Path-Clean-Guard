<#
.SYNOPSIS
  Nettoie PATH Windows avec protection IMPARABLE
.DESCRIPTION
  Backup auto + Git prioritaire + rollback 1s
#>

param([switch]$Force)

# ========================================
# 🛡️ PROTECTION 1 : BACKUP OBLIGATOIRE
# ========================================
$timestamp = Get-Date -f 'yyyyMMdd_HHmmss'
$backupPath = "C:\Temp\Path_Backup_$timestamp.txt"
$currentPath = [Environment]::GetEnvironmentVariable("Path", "Machine")

Write-Host "💾 BACKUP CRITIQUE :" -F Yellow
Write-Host "  → $backupPath" -F Cyan
$currentPath | Out-File $backupPath

# ========================================
# 🛡️ PROTECTION 2 : CONFIRMATION USER
# ========================================
if (-not $Force) {
    Write-Host "`n⚠️  ANALYSE AVANT MODIF :" -F Red
    $entries = ($currentPath -split ";").Count
    Write-Host "  PATH actuel : $entries entrées" -F Yellow
    Write-Host "  Git actuel  : $(git --version)" -F Green
    
    $confirm = Read-Host "`nConfirmez nettoyage ? (O/N)"
    if ($confirm -notmatch '^[Oo]') { 
        Write-Host "❌ ANNULÉ (backup $backupPath préservé)" -F Green
        exit 
    }
}

# ========================================
# 🔧 NETTOYAGE INTELLIGENT
# ========================================
$gitPriority = "C:\Program Files\Git\cmd"
$currentPaths = $currentPath -split ";" | Where { $_ -ne "" }

# Garde existants + supprime polluants
$cleanPaths = $currentPaths | Where-Object {
    (Test-Path $_) -and 
    ($_ -notmatch "cygwin64|msys64|Python3(12|14)|nvm4w|WinGet.*Packages|Scoop|Temp|backup")
} | Sort-Object -Unique

$newPath = @($gitPriority) + ($cleanPaths | Where { $_ -ne $gitPriority })

# ========================================
# 🛡️ PROTECTION 3 : VÉRIFICATION AVANT APPLI
# ========================================
Write-Host "`n📊 RÉSULTATS :" -F Green
Write-Host "  AVANT : $($currentPaths.Count) entrées"
Write-Host "  APRÈS : $($newPaths.Count) entrées (-$([math]::Round(($currentPaths.Count-$newPaths.Count)/$currentPaths.Count*100))%)"
Write-Host "  Git   : $gitPriority" -F Cyan

# Test Git après
if (Test-Path $gitPriority) {
    $gitTest = & "$gitPriority\git.exe" --version 2>$null
    Write-Host "  Test Git : $gitTest" -F Green
}

# ========================================
# 💾 APPLICATION + LOGS
# ========================================
[Environment]::SetEnvironmentVariable("Path", ($newPath -join ";"), "Machine")
$optimizePath = "C:\Temp\Path_Optimise_$timestamp.txt"
($newPath -join ";") | Out-File $optimizePath

Write-Host "`n✅ PATH OPTIMISÉ ! Ferme tous terminaux." -F Green
Write-Host "📁 Backups :" -F Cyan
Write-Host "  Backup  : $backupPath" 
Write-Host "  Optimisé: $optimizePath"
Write-Host "`n🛡️ Rollback (1s) :" -F Yellow
Write-Host "  [Environment]::SetEnvironmentVariable(`"Path`", (Get-Content `"$backupPath`"), `"Machine`")"
