# List stopped services, order alphabetically, and save to CSV
$stoppedServices = Get-Service | Where-Object { $_.Status -eq "Stopped" } | Sort-Object Name
$stoppedServices | Export-Csv -Path "StoppedServices.csv" -NoTypeInformation
Write-Host "Stopped services saved to StoppedServices.csv" -ForegroundColor Green
Write-Host "Total stopped services: $($stoppedServices.Count)" -ForegroundColor Yellow

# Display the CSV contents in a table format
Write-Host "`nDisplaying CSV contents:" -ForegroundColor Cyan
$csvData = Import-Csv -Path "StoppedServices.csv"
$csvData | Format-Table Name, Status, StartType, DisplayName -AutoSize