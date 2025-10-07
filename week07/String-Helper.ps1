<# String-Helper
*************************************************************
   This script contains functions that help with String/Match/Search
   operations. 
************************************************************* 
#>


<# ******************************************************
   Functions: Get Matching Lines
   Input:   1) Text with multiple lines  
            2) Keyword
   Output:  1) Array of lines that contain the keyword
********************************************************* #>
function getMatchingLines($contents, $lookline){

$allines = @()
$splitted =  $contents.split([Environment]::NewLine)

for($j=0; $j -lt $splitted.Count; $j++){  
 
   if($splitted[$j].Length -gt 0){  
        if($splitted[$j] -ilike $lookline){ $allines += $splitted[$j] }
   }

}

return $allines
}



<# ******************************************************
   Functions: Check if User Exists
   Input:   1) Username (string)
   Output:  1) Boolean - true if exists, false if not
********************************************************* #>
function checkUser($name){
   
   # Try to get the user
   $userExists = Get-LocalUser | Where-Object { $_.Name -ilike $name }
   
   # If user exists, return true, otherwise false
   if($userExists){
       return $true
   }
   else{
       return $false
   }
}


<# ******************************************************
   Functions: Check Password Strength
   Input:   1) Password as SecureString
   Output:  1) Boolean - true if valid, false if not
   Requirements:
      - At least 6 characters
      - At least 1 letter (a-z or A-Z)
      - At least 1 number (0-9)
      - At least 1 special character
********************************************************* #>
function checkPassword($password){
    
    # Convert SecureString to plain text for validation
    $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($password)
    $plainPassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
    
    # Check length (at least 6 characters)
    if($plainPassword.Length -lt 6){
        return $false
    }
    
    # Check for at least 1 letter
    if($plainPassword -notmatch "[a-zA-Z]"){
        return $false
    }
    
    # Check for at least 1 number
    if($plainPassword -notmatch "[0-9]"){
        return $false
    }
    
    # Check for at least 1 special character
    if($plainPassword -notmatch "[^a-zA-Z0-9]"){
        return $false
    }
    
    # All checks passed
    return $true
}