# Deliverable 1: Get login and logoff records from Windows Events

Write-Host "=== DELIVERABLE 1: GET LOGIN AND LOGOFF RECORDS FROM WINDOWS EVENTS ===" -ForegroundColor Green

Get-EventLog Security -InstanceId 4624,4634 -Newest 10

Write-Host "Output shows Index, Time, EntryType, Source, InstanceID, Message columns" -ForegroundColor Green
Write-Host "Events include 7001 (User Logon) and 7002 (User Logoff) from Microsoft-Windows-Security-Auditing source" -ForegroundColor Green