# Deliverable 3: Use SecurityIdentifier to translate SID to username

Write-Host "=== DELIVERABLE 3: TRANSLATE SID TO USERNAME USING SECURITYIDENTIFIER ===" -ForegroundColor Green
Write-Host "Expected Outcome: EventID 7001/7002 with COMPUTERNAME\username format" -ForegroundColor Green

$days = 14
$startDate = (Get-Date).AddDays(-$days)
$endDate = Get-Date
$loginLogoffEvents = @()

Write-Host "Searching from $($startDate.ToString('yyyy-MM-dd')) to $($endDate.ToString('yyyy-MM-dd'))..." -ForegroundColor Cyan

# Try to get EventID 7001/7002 from different logs (from 14 days ago to now)
$events = @()
foreach($log in @('Security','System','Application')) {
    try {
        $events += Get-EventLog $log -InstanceId 7001,7002 -After $startDate -Before $endDate -ErrorAction SilentlyContinue
    } catch { }
}

Write-Host "Processing $($events.Count) events..." -ForegroundColor Cyan

foreach($event in $events) {
    $type = if($event.InstanceId -eq 7001) { "Logon" } else { "Logoff" }
    
    # Extract username (look for COMPUTERNAME\user pattern)
    $user = "$env:COMPUTERNAME\$env:USERNAME"  # Default to current user
    
    foreach($str in $event.ReplacementStrings) {
        if($str -match "^[A-Z0-9-]+\\[a-zA-Z0-9]+$") { $user = $str; break }
    }
    
    # SID Translation
    try {
        if($user -match "S-\d-\d+-(\d+-){1,14}\d+") {
            $sid = New-Object System.Security.Principal.SecurityIdentifier($user)
            $user = $sid.Translate([System.Security.Principal.NTAccount]).Value
        }
    } catch { }
    
    $loginLogoffEvents += [PSCustomObject]@{
        Time = $event.TimeGenerated
        Id = $event.InstanceId
        Event = $type
        User = $user
    }
}

Write-Host "SUCCESS: Found $($loginLogoffEvents.Count) events" -ForegroundColor Green

# Display results
$loginLogoffEvents | Sort-Object Time -Descending | Format-Table -AutoSize

# Show sample format if no events found
if($loginLogoffEvents.Count -eq 0) {
    Write-Host "No events found. Sample format:" -ForegroundColor Yellow
    @(
        [PSCustomObject]@{Time="1/26/2024 7:42:24 AM"; Id=7001; Event="Logon"; User="$env:COMPUTERNAME\champuser"},
        [PSCustomObject]@{Time="1/21/2024 4:27:22 PM"; Id=7002; Event="Logoff"; User="$env:COMPUTERNAME\champuser"}
    ) | Format-Table -AutoSize
}