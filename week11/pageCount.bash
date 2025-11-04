#!/bin/bash

# Script with pageCount function to count how many times each page was accessed

pageCount() {
    echo "Page Access Count:"
    echo "=================="

    # Extract the page names (7th field which contains the request path)
    # Filter for .html files, sort them, and count unique occurrences
    cat /var/log/apache2/access.log | cut -d ' ' -f 7 | grep ".html" | sort | uniq -c

    echo ""
    echo "Explanation:"
    echo "- cut -d ' ' -f 7: extracts the 7th field (requested page)"
    echo "- grep '.html': filters only HTML pages"
    echo "- sort: sorts the pages alphabetically"
    echo "- uniq -c: counts consecutive identical lines"
}

# Call the function
pageCount
