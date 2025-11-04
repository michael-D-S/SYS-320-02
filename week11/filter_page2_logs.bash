#!/bin/bash

# Script to display only IP address and page name for page2.html access records
# This uses pipes with cut, grep, and tr (trim) commands

echo "Filtering Apache logs for page2.html access..."
echo ""

# Filter for page2.html, then extract IP address and page name
cat /var/log/apache2/access.log | grep "page2.html" | cut -d ' ' -f 1,7

# Alternative version that removes the [GET prefix if needed:
# cat /var/log/apache2/access.log | grep "page2.html" | cut -d ' ' -f 1,7 | tr -d '['
