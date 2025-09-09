# List every process where the path does not include "system32"
Write-Host "`n=== Task 2: Processes not in system32 ===" -ForegroundColor Green
Get-Process | Where-Object { $_.Path -and $_.Path -notlike "*system32*" } | Select-Object ProcessName, Id, Path | Format-Table