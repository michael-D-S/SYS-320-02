# Uses dot notation to call functions
# Load the functions using PSScriptRoot
. "$PSScriptRoot\Parsing-logs.ps1"

Write-Host "=== SYS-320 Apache Log Analysis ===" -ForegroundColor Green

# Check if access.log exists, if not create sample data
if (-not (Test-Path "access.log")) {
    Write-Host "`nNo access.log found. Creating sample log file..." -ForegroundColor Yellow
    New-SampleApacheLog -LogPath "access.log"
}

# Note about 10.* network filtering
Write-Host "`nNote: This analysis filters for IPs in the 10.* network range only" -ForegroundColor Cyan

# Example 1: Find IPs that accessed index.html with 200 status
Write-Host "`n1. IPs that accessed index.html successfully:"
$ips1 = Get-ApacheLogIPs -PageVisited "index.html" -HttpCode "200" -Browser ".*"
Write-Host "Found $($ips1.Count) unique IPs: $($ips1 -join ', ')"

# Example 2: Find all 404 errors
Write-Host "`n2. IPs that got 404 errors:"
$ips2 = Get-ApacheLogIPs -PageVisited ".*" -HttpCode "404" -Browser ".*"
Write-Host "Found $($ips2.Count) unique IPs: $($ips2 -join ', ')"

# Example 3: Find Chrome users
Write-Host "`n3. IPs using Chrome browser:"
$ips3 = Get-ApacheLogIPs -PageVisited ".*" -HttpCode "200" -Browser "Chrome"
Write-Host "Found $($ips3.Count) unique IPs: $($ips3 -join ', ')"

# Interactive example
Write-Host "`n=== Your Turn ===" -ForegroundColor Yellow

$page = Read-Host "Enter page name (or .* for any)"
$code = Read-Host "Enter HTTP code (200, 404, etc)"
$browser = Read-Host "Enter browser (Chrome, Firefox, or .* for any)"

$userIPs = Get-ApacheLogIPs -PageVisited $page -HttpCode $code -Browser $browser

Write-Host "`nYour results: Found $($userIPs.Count) unique IPs: $($userIPs -join ', ')" -ForegroundColor Cyan

Write-Host "`nDone!" -ForegroundColor Green