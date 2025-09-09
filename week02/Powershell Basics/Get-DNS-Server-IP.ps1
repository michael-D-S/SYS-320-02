# Get dns server ips and display only the 1st one
(Get-DnsClientServerAddress -AddressFamily IPv4 |
 Where-Object {$_.InterfaceAlias -ilike "*Ethernet*"}).ServerAddresses[0]