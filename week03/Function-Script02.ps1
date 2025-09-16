# Deliverable 4 & 5: Login/Logoff and Startup/Shutdown Functions
Write-Host "=== DELIVERABLE 4 & 5: LOGIN/LOGOFF AND STARTUP/SHUTDOWN FUNCTIONS ===" -ForegroundColor Green
Write-Host "Expected Outcome: Two functions with same properties (Time, Id, Event, User)" -ForegroundColor Green

# Deliverable 4: Login/Logoff Function
function Get-LoginLogoffEvents {
    param(
        [int]$days  # Input: number of days for logs
    )
    
    Write-Host "Login/Logoff function executing with $days days parameter..." -ForegroundColor Cyan
    
    $startDate = (Get-Date).AddDays(-$days)
    $endDate = Get-Date
    $loginLogoffEvents = @()
    
    # Try to get EventID 7001/7002 from different logs
    $events = @()
    foreach($log in @('Security','System','Application')) {
        try {
            $events += Get-EventLog $log -InstanceId 7001,7002 -After $startDate -Before $endDate -ErrorAction SilentlyContinue
        } catch { }
    }
    
    Write-Host "Processing $($events.Count) login/logoff events..." -ForegroundColor Yellow
    
    foreach($event in $events) {
        $type = if($event.InstanceId -eq 7001) { "Logon" } else { "Logoff" }
        
        # Extract actual username from event
        $user = $null
        
        # For 7001 (Logon) events: try different indices
        if($event.InstanceId -eq 7001 -and $event.ReplacementStrings.Count -gt 5) {
            $targetUser = $event.ReplacementStrings[5]  # Target Username
            $targetDomain = $event.ReplacementStrings[6]  # Target Domain
            if($targetUser -and $targetUser -ne "-" -and $targetUser -notlike "*$") {
                $user = if($targetDomain -and $targetDomain -ne "-") { "$targetDomain\$targetUser" } else { $targetUser }
            }
        }
        # For 7002 (Logoff) events: try different indices  
        elseif($event.InstanceId -eq 7002 -and $event.ReplacementStrings.Count -gt 1) {
            $targetUser = $event.ReplacementStrings[1]  # Target Username
            $targetDomain = $event.ReplacementStrings[2]  # Target Domain
            if($targetUser -and $targetUser -ne "-" -and $targetUser -notlike "*$") {
                $user = if($targetDomain -and $targetDomain -ne "-") { "$targetDomain\$targetUser" } else { $targetUser }
            }
        }
        
        # If no user found, try to find any username pattern in ReplacementStrings
        if(-not $user) {
            foreach($str in $event.ReplacementStrings) {
                if($str -match "^[A-Z0-9-]+\\[a-zA-Z0-9]+$" -and $str -notlike "*SYSTEM*") { 
                    $user = $str; break 
                }
            }
        }
        
        # Default to current user if nothing found
        if(-not $user) {
            $user = "$env:COMPUTERNAME\$env:USERNAME"
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
    
    Write-Host "SUCCESS: Login/Logoff function found $($loginLogoffEvents.Count) events" -ForegroundColor Green
    
    # Return table of results
    return $loginLogoffEvents
}

# Deliverable 5: Startup/Shutdown Function
function Get-StartupShutdownEvents {
    param(
        [int]$days  # Input: number of days for logs
    )
    
    Write-Host "Startup/Shutdown function executing with $days days parameter..." -ForegroundColor Cyan
    
    $startDate = (Get-Date).AddDays(-$days)
    $endDate = Get-Date
    $systemEvents = @()
    
    # Get EventId 6005 (startup) and 6006 (shutdown) from System log
    try {
        $events = Get-EventLog System -After $startDate -Before $endDate -ErrorAction SilentlyContinue | 
                  Where-Object { $_.EventID -eq 6005 -or $_.EventID -eq 6006 }
    } catch {
        $events = @()
    }
    
    Write-Host "Processing $($events.Count) startup/shutdown events..." -ForegroundColor Yellow
    
    foreach($event in $events) {
        # Event: Assign custom string value based on EventId
        $eventType = switch ($event.EventID) {
            6005 { "Startup" }   # System startup
            6006 { "Shutdown" }  # System shutdown
            default { "Unknown" }
        }
        
        # Extract actual username from event (instead of just "System")
        $user = $null
        
        # Try to get user from ReplacementStrings first
        if($event.ReplacementStrings -and $event.ReplacementStrings.Count -gt 0) {
            foreach($str in $event.ReplacementStrings) {
                if($str -match "^[A-Z0-9-]+\\[a-zA-Z0-9]+$" -and $str -notlike "*SYSTEM*") { 
                    $user = $str; break 
                }
            }
        }
        
        # Try to get user from event message
        if(-not $user -and $event.Message) {
            if($event.Message -match "([A-Z0-9-]+\\[a-zA-Z0-9]+)") {
                $user = $matches[1]
            }
        }
        
        # Get current logged-in user as fallback (instead of "System")
        if(-not $user) {
            $user = "$env:COMPUTERNAME\$env:USERNAME"
        }
        
        # Create object with same properties as first function
        $systemEvents += [PSCustomObject]@{
            Time = $event.TimeGenerated    # Time: TimeGenerated from event logs
            Id = $event.EventID            # Id: EventId (Not InstanceId)
            Event = $eventType             # Event: Custom string based on EventId
            User = $user                   # User: Real username instead of "System"
        }
    }
    
    Write-Host "SUCCESS: Startup/Shutdown function found $($systemEvents.Count) events" -ForegroundColor Green
    
    # Return table of results
    return $systemEvents
}

# Get user input for parameter
$userDays = Read-Host "Enter number of days to search back for events"

# Call login/logoff function
Write-Host "`nCalling Get-LoginLogoffEvents function with $userDays days parameter..." -ForegroundColor Cyan
$loginResults = Get-LoginLogoffEvents -days $userDays

Write-Host "`nLogin/Logoff Results:" -ForegroundColor Yellow
$loginResults | Sort-Object Time -Descending | Format-Table -AutoSize

# Call startup/shutdown function
Write-Host "`nCalling Get-StartupShutdownEvents function with $userDays days parameter..." -ForegroundColor Cyan
$systemResults = Get-StartupShutdownEvents -days $userDays

Write-Host "`nStartup/Shutdown Results:" -ForegroundColor Yellow
$systemResults | Sort-Object Time -Descending | Format-Table -AutoSize

# Show sample formats if no events found
if($loginResults.Count -eq 0) {
    Write-Host "No login/logoff events found. Sample format:" -ForegroundColor Yellow
    @(
        [PSCustomObject]@{Time="1/26/2024 7:42:24 AM"; Id=7001; Event="Logon"; User="$env:COMPUTERNAME\champuser"},
        [PSCustomObject]@{Time="1/21/2024 4:27:22 PM"; Id=7002; Event="Logoff"; User="$env:COMPUTERNAME\champuser"}
    ) | Format-Table -AutoSize
}

if($systemResults.Count -eq 0) {
    Write-Host "No startup/shutdown events found. Sample format:" -ForegroundColor Yellow
    @(
        [PSCustomObject]@{Time="1/26/2024 8:00:00 AM"; Id=6005; Event="Startup"; User="System"},
        [PSCustomObject]@{Time="1/25/2024 6:00:00 PM"; Id=6006; Event="Shutdown"; User="System"}
    ) | Format-Table -AutoSize
}

# Summary

Write-Host "`nBoth functions executed with same user input ($userDays days):" -ForegroundColor Green
Write-Host "  • Login/Logoff events found: $($loginResults.Count)" -ForegroundColor Cyan
Write-Host "  • Startup/Shutdown events found: $($systemResults.Count)" -ForegroundColor Cyan
Write-Host "  • Total events processed: $($loginResults.Count + $systemResults.Count)" -ForegroundColor Cyan