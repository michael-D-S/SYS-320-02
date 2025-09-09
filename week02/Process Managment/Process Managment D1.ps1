# List all processes with ProcessName starting with "C"
Write-Host "=== Task 1: Processes starting with 'C' ===" -ForegroundColor Green
Get-Process | Where-Object { $_.ProcessName -like "C*" } | Select-Object ProcessName, Id, CPU, WorkingSet | Format-Table
