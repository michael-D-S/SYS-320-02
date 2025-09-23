function Get-ApacheLogIPs {
    param(
        $PageVisited,
        $HttpCode, 
        $Browser
    )
    
    $logPath = "C:\xampp\apache\logs"
    $matchingIPs = @()
    
    # Get all log files
    $logFiles = Get-ChildItem -Path $logPath -Filter "*.log"
    
    foreach ($logFile in $logFiles) {
        $logContent = Get-Content -Path $logFile.FullName
        
        foreach ($line in $logContent) {
            # Simple regex to parse Apache logs
            if ($line -match '^(\S+).*".*(\S+).*" (\d+).*"([^"]*)"') {
                $ip = $matches[1]
                $page = $matches[2]
                $status = $matches[3]
                $userAgent = $matches[4]
                
                # Check if matches criteria
                $pageMatch = ($page -like "*$PageVisited*" -or $PageVisited -eq ".*")
                $statusMatch = ($status -eq $HttpCode -or $HttpCode -eq ".*")
                $browserMatch = ($userAgent -like "*$Browser*" -or $Browser -eq ".*")
                
                if ($pageMatch -and $statusMatch -and $browserMatch) {
                    $matchingIPs += $ip
                }
            }
        }
    }
    
    return $matchingIPs | Sort-Object | Get-Unique
}