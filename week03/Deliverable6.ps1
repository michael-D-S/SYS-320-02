# Deliverable 6: Use dot notation to call functions from first script file

# Use dot notation to load functions from Function-Script02.ps1
. (Join-Path $psScriptRoot "Function-Script02.ps1")

clear

# Get Login and Logoffs from the last 15 days
$loginoutsTable = Get-LoginLogoffEvents -days 15
$loginoutsTable

# Get Shut Downs from the last 25 days
$shutdownsTable = Get-StartupShutdownEvents -days 25 | Where-Object {$_.Event -eq "Shutdown"}
$shutdownsTable

# Get Start Ups from the last 25 days
$startupsTable = Get-StartupShutdownEvents -days 25 | Where-Object {$_.Event -eq "Startup"}
$startupsTable