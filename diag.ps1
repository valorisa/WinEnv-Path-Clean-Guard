# Diagnostic PATH Git Bertrand - SAFE READ-ONLY
Write-Host "=== GIT DIAGNOSTIC Bertrand ===" -ForegroundColor Green
git --version
where.exe git

Write-Host "`n=== PATH LENGTH ===" -ForegroundColor Yellow
($env:Path.Split(';') | Measure-Object).Count

Write-Host "`n=== DOUBLONS PATH ===" -ForegroundColor Red
$env:Path.Split(';') | Group-Object | Where-Object {$_.Count -gt 1}

Write-Host "`n=== Git LOCATIONS ===" -ForegroundColor Cyan
Get-ChildItem Env:Path | Select-String "git" -AllMatches
