. (Join-Path $PSScriptRoot Users.ps1)
. (Join-Path $PSScriptRoot Event-Logs.ps1)

clear

$Prompt = "`n"
$Prompt += "Please choose your operation:`n" 
$Prompt += "1 - List Enabled Users`n"
$Prompt += "2 - List Disabled Users`n"
$Prompt += "3 - Create a User`n"
$Prompt += "4 - Remove a User`n"
$Prompt += "5 - Enable a User`n"
$Prompt += "6 - Disable a User`n"
$Prompt += "7 - Get Log-In Logs`n"
$Prompt += "8 - Get Failed Log-In Logs`n"
$Prompt += "9 - List At Risk Users`n"
$Prompt += "10 - Exit`n"



$operation = $true

while($operation){

    
    Write-Host $Prompt -ForegroundColor Green
    $choice = Read-Host


    if($choice -eq 10){
        Write-Host "Goodbye" -ForegroundColor Green
        exit
        $operation = $false 
    }

    elseif($choice -eq 1){
        $enabledUsers = getEnabledUsers
        Write-Host ($enabledUsers | Format-Table | Out-String)
    }

    elseif($choice -eq 2){
        $notEnabledUsers = getNotEnabledUsers
        Write-Host ($notEnabledUsers | Format-Table | Out-String)
    }


    # Create a user
    elseif($choice -eq 3){ 

        $name = Read-Host -Prompt "Please enter the username for the new user"

        # Check if user already exists
        if(checkUser $name){
            Write-Host "Error: User '$name' already exists. Please choose a different username." | Out-String
            continue
        }
        
        $password = Read-Host -AsSecureString -Prompt "Please enter the password for the new user"

        # Validate password strength
        if(-not (checkPassword $password)){
            Write-Host "Error: Password does not meet security requirements." | Out-String -ForegroundColor Red
            Write-Host "Password must have:" | Out-String -ForegroundColor Red
            Write-Host "  - At least 6 characters" | Out-String -ForegroundColor Red
            Write-Host "  - At least 1 letter" | Out-String -ForegroundColor Red
            Write-Host "  - At least 1 number" | Out-String -ForegroundColor Red
            Write-Host "  - At least 1 special character" | Out-String -ForegroundColor Red
            continue
        }

        # TODO: Create a function called checkUser in Users that: 
        #              - Checks if user a exists. 
        #              - If user exists, returns true, else returns false
        # TODO: Check the given username with your new function.
        #              - If false is returned, continue with the rest of the function
        #              - If true is returned, do not continue and inform the user
        #
        # TODO: Create a function called checkPassword in String-Helper that:
        #              - Checks if the given string is at least 6 characters
        #              - Checks if the given string contains at least 1 special character, 1 number, and 1 letter
        #              - If the given string does not satisfy conditions, returns false
        #              - If the given string satisfy the conditions, returns true
        # TODO: Check the given password with your new function. 
        #              - If false is returned, do not continue and inform the user
        #              - If true is returned, continue with the rest of the function

        createAUser $name $password

        Write-Host "User: $name is created." | Out-String
    }


    # Remove a user
    elseif($choice -eq 4){

        $name = Read-Host -Prompt "Please enter the username for the user to be removed"

        # TODO: Check the given username with the checkUser function.
        
        # Check if user exists
        if(-not (checkUser $name)){
            Write-Host "Error: User '$name' does not exist." | Out-String
            continue
        }

        removeAUser $name

        Write-Host "User: $name Removed." | Out-String
    }


    # Enable a user
    elseif($choice -eq 5){


        $name = Read-Host -Prompt "Please enter the username for the user to be enabled"

        # TODO: Check the given username with the checkUser function.
        
        # Check if user exists
        if(-not (checkUser $name)){
            Write-Host "Error: User '$name' does not exist." | Out-String
            continue
        }

        enableAUser $name

        Write-Host "User: $name Enabled." | Out-String
    }


    # Disable a user
    elseif($choice -eq 6){

        $name = Read-Host -Prompt "Please enter the username for the user to be disabled"

        # TODO: Check the given username with the checkUser function.
        
        # Check if user exists
        if(-not (checkUser $name)){
            Write-Host "Error: User '$name' does not exist." | Out-String
            continue
        }


        disableAUser $name

        Write-Host "User: $name Disabled." | Out-String
    }


    elseif($choice -eq 7){

        $name = Read-Host -Prompt "Please enter the username for the user logs"

        # Check if user exists
        if(-not (checkUser $name)){
            Write-Host "Error: User '$name' does not exist." | Out-String
            continue
        }

        # Get number of days from user
        $days = Read-Host -Prompt "Please enter the number of days to look back"

        $userLogins = getLogInAndOffs $days

        Write-Host ($userLogins | Where-Object { $_.User -ilike "*$name"} | Format-Table | Out-String)
    }



    elseif($choice -eq 8){

        $name = Read-Host -Prompt "Please enter the username for the user's failed login logs"

        # TODO: Check the given username with the checkUser function.
        # TODO: Change the above line in a way that, the days 90 should be taken from the user

        
        # Check if user exists
        if(-not (checkUser $name)){
            Write-Host "Error: User '$name' does not exist." | Out-String
            continue
        }

        # Get number of days from user
        $days = Read-Host -Prompt "Please enter the number of days to look back"

        $userLogins = getFailedLogins $days

        Write-Host ($userLogins | Where-Object { $_.User -ilike "*$name"} | Format-Table | Out-String)
    }

       # List at Risk Users
    elseif($choice -eq 9){

        # Get number of days from user
        $days = Read-Host -Prompt "Enter number of days to analyze for at-risk users"

        # Get all failed logins for the specified time period
        $failedLogins = getFailedLogins $days

        # Group the failed logins by username and count them
        $groupedFailures = $failedLogins | Group-Object -Property User

        # Filter to only users with more than 10 failed logins
        $atRiskUsers = $groupedFailures | Where-Object { $_.Count -gt 10 }

        # Check if any at-risk users were found
        if($atRiskUsers.Count -eq 0){
            Write-Host "No at-risk users found (users with more than 10 failed logins)." | Out-String
        }
        else{
            Write-Host "`nAt-Risk Users (More than 10 failed logins in last $days days):" | Out-String
            Write-Host ($atRiskUsers | Select-Object Name, Count | Format-Table | Out-String)
        }

    }
    # Input validation - catch invalid choices
    else{
        Write-Host "`nInvalid choice. Please enter a number between 1 and 10." -ForegroundColor Red
    }
    # TODO: Create another choice "List at Risk Users" that
    #              - Lists all the users with more than 10 failed logins in the last <User Given> days.  
    #                (You might need to create some failed logins to test)
    #              - Do not forget to update prompt and option numbers
    
    # TODO: If user enters anything other than listed choices, e.g. a number that is not in the menu   
    #       or a character that should not be accepted. Give a proper message to the user and prompt again.
    

}




