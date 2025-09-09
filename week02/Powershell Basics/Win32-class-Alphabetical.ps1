# Show what classes there is of Win32 library that start with Net, Sort alphabetically
Get-WmiObject -List | Where-Object { $_.Name -like "Win32_Net*" } | Sort-Object Name