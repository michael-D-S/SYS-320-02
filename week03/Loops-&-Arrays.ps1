# Deliverable 2: Create custom objects with loops and arrays

Write-Host "=== DELIVERABLE 2: CREATE CUSTOM OBJECTS USING LOOPS AND ARRAYS ===" -ForegroundColor Green
Write-Host "Expected Outcome: Empty array, foreach loop, custom PSCustomObject with 4 properties" -ForegroundColor Green

# Step 1: Create empty array
Write-Host "`nCreating empty array..." -ForegroundColor Cyan
$days = 14
$daysAgo = (Get-Date).AddDays(-$days)
$loginLogoffEvents = @()

Write-Host "SUCCESS: Empty array `$loginLogoffEvents created" -ForegroundColor Green

# Step 2: Get events for last 14 days
Write-Host "`nGetting events from last 14 days..." -ForegroundColor Cyan
$events = Get-EventLog Security -InstanceId 4624,4634 -After $daysAgo

Write-Host "SUCCESS: Retrieved $($events.Count) events from Security log" -ForegroundColor Green

# Step 3: Loop over each log and create custom objects
Write-Host "`nProcessing events with foreach loop to create custom objects..." -ForegroundColor Cyan

foreach($event in $events) {
    if($event.InstanceId -eq 4624) {
        $type = "Logon"
    } else {
        $type = "Logoff"
    }
    
    $user = $event.ReplacementStrings[5]
    
    if($user -and $user -notlike "*$") {
        # Create custom object with exactly 4 properties as specified
        $loginLogoffEvents += [PSCustomObject]@{
            Time = $event.TimeGenerated
            Id = $event.InstanceId  
            Event = $type
            User = $user
        }
    }
}

Write-Host "SUCCESS: Created $($loginLogoffEvents.Count) custom objects with 4 properties each" -ForegroundColor Green

# Display results
Write-Host "`nDisplaying custom objects (Time, Id, Event, User):" -ForegroundColor Yellow
$loginLogoffEvents | Sort-Object Time -Descending | Select-Object -First 14 | Format-Table