#!/bin/bash

# Function to count curl accesses from different IP addresses
countingCurlAccess() {
    echo "Counting Curl Access by IP Address:"
    echo "===================================="
    echo ""

    # Grep for "curl" in the user agent field, extract IP addresses, sort, and count unique IPs
    cat /var/log/apache2/access.log | grep -i "curl" | cut -d ' ' -f 1 | sort | uniq -c

    echo ""
    echo "Explanation:"
    echo "- grep -i 'curl': finds all lines with 'curl' (case-insensitive)"
    echo "- cut -d ' ' -f 1: extracts the IP address (field 1)"
    echo "- sort: sorts IP addresses alphabetically"
    echo "- uniq -c: counts each unique IP address"
}

# Call the function
countingCurlAccess
