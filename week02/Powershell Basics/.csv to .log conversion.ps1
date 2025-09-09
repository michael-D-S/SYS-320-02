# Without changing directory, find every .csv file recursivly and change its extention to .log
# Recursively display all the files
$files = Get-ChildItem -Recurse -Include *.csv
$files | ForEach-Object { Rename-Item $_.FullName -NewName ($_.Name -replace '.csv', '.log') }
Get-ChildItem -Recurse