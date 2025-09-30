function daysTranslator($FullTable){

    # Go over every record in the table
    for($i=0; $i -lt $FullTable.length; $i++){

        # Empty array to hold days for every record
        $Days = @()
        
        # If you see "M" -> Monday
        if($FullTable[$i].Days -ilike "*M*"){ $Days += "Monday" }
        
        # If you see "T" followed by T,W, or F -> Tuesday
        if($FullTable[$i].Days -ilike "*T[TWF]*"){ $Days += "Tuesday" }
        # If you only see "T" -> Tuesday
        ElseIf($FullTable[$i].Days -ilike "T"){ $Days += "Tuesday" }
        
        # If you see "W" -> Wednesday
        if($FullTable[$i].Days -ilike "*W*"){ $Days += "Wednesday" }
        
        # If you see "TH" -> Thursday
        if($FullTable[$i].Days -ilike "*TH*"){ $Days += "Thursday" }
        
        # F -> Friday
        if($FullTable[$i].Days -ilike "*F*"){ $Days += "Friday" }
        
        # Make the switch
        $FullTable[$i].Days = $Days
    }

    return $FullTable
}