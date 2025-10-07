# Source previous lab scripts
. (Join-Path $PSScriptRoot "Apache-Logs.ps1")
. (Join-Path $PSScriptRoot "Process Managment D4-Chrome.ps1")
. (Join-Path $PSScriptRoot "Event-Logs.ps1")

clear

$Prompt = "`n==================================`n"
$Prompt += "   System Administration Menu`n"
$Prompt += "==================================`n"
$Prompt += "1 - Display last 10 apache logs`n"
$Prompt += "2 - Display last 10 failed logins`n"
$Prompt += "3 - Display at risk users`n"
$Prompt += "4 - Start Chrome (champlain.edu)`n"
$Prompt += "5 - Exit`n"
$Prompt += "==================================`n"

$operation = $true

while($operation){
    
    Write-Host $Prompt -ForegroundColor Cyan
    Write-Host "Enter choice (1-5): " -ForegroundColor Yellow -NoNewline
    $choice = Read-Host

    # Validate input
    if($choice -notmatch '^[1-5]$'){
        Write-Host "`n[ERROR] Invalid choice. Enter 1-5.`n" -ForegroundColor Red
        continue
    }

    # Option 1: Apache logs
    if($choice -eq 1){
        Write-Host "`n=== Apache Logs ===`n" -ForegroundColor Magenta
        
        $apacheIPs = Get-ApacheLogIPs -PageVisited ".*" -HttpCode ".*" -Browser ".*"
        
        if($apacheIPs.Count -eq 0){
            Write-Host "No Apache logs found.`n" -ForegroundColor Yellow
        }
        else{
            $lastTen = $apacheIPs | Select-Object -Last 10
            $counter = 1
            foreach($ip in $lastTen){
                Write-Host "[$counter] $ip" -ForegroundColor White
                $counter++
            }
            Write-Host "`nTotal IPs: $($apacheIPs.Count)`n" -ForegroundColor Cyan
        }
        
        Write-Host "Press Enter to continue..." -ForegroundColor Yellow
        $null = Read-Host
    }

    # Option 2: Failed logins
    elseif($choice -eq 2){
        Write-Host "`n=== Failed Logins ===`n" -ForegroundColor Magenta
        
        $failedLogins = getFailedLogins 30
        
        if($failedLogins.Count -eq 0){
            Write-Host "No failed logins in last 30 days.`n" -ForegroundColor Green
        }
        else{
            $lastTen = $failedLogins | Select-Object -Last 10
            Write-Host ($lastTen | Format-Table Time, User, Event -AutoSize | Out-String) -ForegroundColor White
            Write-Host "Total: $($failedLogins.Count)`n" -ForegroundColor Yellow
        }
        
        Write-Host "Press Enter to continue..." -ForegroundColor Yellow
        $null = Read-Host
    }

    # Option 3: At risk users
    elseif($choice -eq 3){
        Write-Host "`n=== At-Risk Users ===`n" -ForegroundColor Magenta
        
        $failedLogins = getFailedLogins 30
        $groupedFailures = $failedLogins | Group-Object -Property User
        $atRiskUsers = $groupedFailures | Where-Object { $_.Count -gt 10 }
        
        if($atRiskUsers.Count -eq 0){
            Write-Host "No at-risk users found.`n" -ForegroundColor Green
        }
        else{
            Write-Host ($atRiskUsers | Select-Object Name, Count | Format-Table -AutoSize | Out-String) -ForegroundColor Red
            Write-Host "Total at-risk: $($atRiskUsers.Count)`n" -ForegroundColor Red
        }
        
        Write-Host "Press Enter to continue..." -ForegroundColor Yellow
        $null = Read-Host
    }

    # Option 4: Chrome
    elseif($choice -eq 4){
        Write-Host "`n=== Launching Chrome ===`n" -ForegroundColor Magenta
        
        $chromeRunning = Get-Process -Name "chrome" -ErrorAction SilentlyContinue
        
        if($chromeRunning){
            Write-Host "Chrome already running - opening new tab`n" -ForegroundColor Yellow
        }
        else{
            Write-Host "Starting Chrome`n" -ForegroundColor Cyan
        }
        
        Start-Process "chrome.exe" "https://www.champlain.edu"
        Write-Host "Done!`n" -ForegroundColor Green
        
        Write-Host "Press Enter to continue..." -ForegroundColor Yellow
        $null = Read-Host
    }

    # Option 5: Exit
    elseif($choice -eq 5){
        Write-Host "`nGoodbye!`n" -ForegroundColor Blue
        exit
    }

}