<#
.SYNOPSIS
  Status complet PATH + Git + Performances
#>

Clear-Host
Write-Host "🔍 WINENV-PATH-CHECK v1.0" -F Cyan

# ========================================
# 1. GIT STATUS
# ========================================
Write-Host "`n📊 GIT STATUS" -F Green
Write-Host "Version : $(git --version)"
Write-Host "Chemin  : $(Get-Command git | Select -Expand Path)"

# ========================================
# 2. PATH ANALYSIS
# ========================================
$currentPath = [Environment]::GetEnvironmentVariable("Path", "Machine")
$entries = ($currentPath -split ";").Count
Write-Host "`n📈 PATH ANALYSIS" -F Yellow
Write-Host "Total entrées : $entries"

# Orphelins
$orphans = ($currentPath -split ";" | Where { $_ -and -(Test-Path $_) }).Count
Write-Host "Orphelins     : $orphans"

# Redondances
$dups = ($currentPath -split ";" | Group-Object | Where Count -gt 1).Count
Write-Host "Redondances   : $dups"

# Git position
$gitPos = ($currentPath -split ";" | Select-String "Git").Count
Write-Host "Git dans PATH : $gitPos"

# ========================================
# 3. PERFORMANCE TEST
# ========================================
Write-Host "`n⚡ PERFORMANCE" -F Magenta
$time = Measure-Command { Get-Command git } 
Write-Host "Résolution Git: $($time.TotalMilliseconds)ms"

# ========================================
# 4. BACKUPS CHECK
# ========================================
$backups = Get-ChildItem "C:\Temp\Path_*" | Sort LastWriteTime -Descending
Write-Host "`n💾 BACKUPS RÉCENTS" -F Cyan
$backups | Select -First 3 | ForEach { 
    $count = (Get-Content $_.FullName -split ";").Count
    Write-Host "  $($_.Name) ($count entrées)"
}

# ========================================
# 5. STATUS COULEUR
# ========================================
Write-Host "`n🎯 STATUS FINAL :" -F White -NoNewline
if ($entries -le 60 -and $orphans -le 5 -and $dups -eq 0) {
    Write-Host "✅ OPTIMAL" -F Green
} elseif ($entries -gt 70) {
    Write-Host "⚠️  TROP VOLUMINEUX (GUI risque)" -F Red
} else {
    Write-Host "ℹ️  OK (maintenance conseillée)" -F Yellow
}
