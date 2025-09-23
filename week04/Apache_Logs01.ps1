<#
# List all the apache logs of xampp
#Get-Content C:\xampp\apache\logs\access.log

# List only the last 5 apache logs
#Get-Content C:\xampp\apache\logs\access.log -Tail 5

# Display only logs that contain 404 (Not Found) or 400 (Bad Request)
#Get-Content C:\xampp\apache\logs\access.log | Select-String '" 404 ','" 400 '

# Display only logs that does NOT contain 200 (OK)
#Get-Content C:\xampp\apache\logs\access.log | Select-String '200' -NotMatch

# From every file in the directory, only get logs that contains the word 'error'
#$A = Get-ChildItem C:\xampp\apache\logs\*.log | Select-String 'error'
# Display last 5 elements of the result array
#$A | Select-Object -Last 5
#>

<#
# Get only logs that contain 404, save into $notfounds
$notfounds = Get-Content C:\xampp\apache\logs\access.log | Select-String '404'

# Define a regex for IP addresses
$regex = [regex] "^(?:[0-9]{1,3}\.){3}[0-9]{1,3}"

# Get $notfounds records that match to the regex
$ipsunorganized = $notfounds | ForEach-Object { $regex.Matches($_.Line) }

# Get ips as pscustomobject
$ips = @()
for($i=0; $i -lt $ipsunorganized.count; $i++){
    $ips += [PSCustomObject]@{"IP" = $ipsunorganized[$i].Value; }
}
$ips | Where-Object { $_.IP -like "*" }
#>

# Count ips from number 8
$ipsoftens = $ips | where-Object { $_.IP -ilike "*" }
$counts = $ipsoftens | Group-Object IP
$counts | Select-Object Count, Name