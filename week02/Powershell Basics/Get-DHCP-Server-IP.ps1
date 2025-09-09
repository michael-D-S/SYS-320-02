# Get dhcp server IP and hide the table headers
Get-CimInstance Win32_NetworkAdapterConfiguration -Filter "DHCPEnabled='True'" |
 Select DHCPServer | Format-Table -H