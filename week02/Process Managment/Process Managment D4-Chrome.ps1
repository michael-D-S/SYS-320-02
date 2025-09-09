# Chrome management script
Write-Host "`n=== Task 4: Chrome Management ===" -ForegroundColor Green
# Check if Chrome is running
$chromeProcess = Get-Process -Name "chrome" -ErrorAction SilentlyContinue

if ($chromeProcess) {
    Write-Host "Chrome is running. Stopping all Chrome processes..." -ForegroundColor Yellow
    Stop-Process -Name "chrome" -Force
    Write-Host "Chrome has been stopped." -ForegroundColor Red
} else {
    Write-Host "Chrome is not running. Starting Chrome and navigating to Champlain.edu..." -ForegroundColor Yellow
    Start-Process "chrome.exe" "https://champlain.edu"
    Write-Host "Chrome started and directed to Champlain.edu" -ForegroundColor Green
}