# Use full or relative path with dot sourcing
. "$PSScriptRoot\Course-Scrapping-Function.ps1"
. "$PSScriptRoot\daysTranslator.ps1"
# Call the function
$results = gatherClasses

# Pass the table to the translator function
$translatedResults = daysTranslator $results

# Display the results
#$translatedResults
<#
# List all the classes of instructor Furkan Paligu
$translatedResults | Where-Object { $_."Instructor" -eq "Furkan Paligu" } | Select-Object "Class Code", "Instructor", Location, Days, "Time Start", "Time End"
#>
<#
# List all the classes of JOYC 310 on Mondays, only display Class Code and Times
# Sort by Start Time
$translatedResults | Where-Object { ($_.Location -eq "JOYC 310") -and ($_.days -contains "Monday") } |
             Sort-Object "Time Start" |
             Select-Object "Time Start", "Time End", "Class Code"
#>
<#
# Make a list of all the instructors that teach at least 1 course in
# SYS, SEC, NET, FOR, CSI, DAT
# Sort by name, and make it unique
$ITSInstructors = $FullTable | Where-Object { ($_."Class Code" -like "SYS*") -or
                                               ($_."Class Code" -like "NET*") -or
                                               ($_."Class Code" -like "SEC*") -or
                                               ($_."Class Code" -like "FOR*") -or
                                               ($_."Class Code" -like "CSI*") -or
                                               ($_."Class Code" -like "DAT*") } |
                               Select-Object "Instructor" |
                               Sort-Object "Instructor" -Unique

$ITSInstructors
#>

# Group all the instructors by the number of classes they are teaching
$FullTable | Where-Object { $_.Instructor -in $ITSInstructors.Instructor } |
             Group-Object "Instructor" |
             Select-Object Count,Name |
             Sort-Object Count -Descending