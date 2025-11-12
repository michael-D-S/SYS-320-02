#! /bin/bash

logFile="/var/log/apache2/access.log"
flaggedUsersFile="flagged_users.txt"

# Function: displayAllLogs
# Purpose: Display complete, unfiltered log file contents
function displayAllLogs(){
	cat "$logFile"
}

# Function: displayOnlyIPs
# Purpose: Extract and count unique IP addresses
function displayOnlyIPs(){
	cat "$logFile" | cut -d ' ' -f 1 | sort -n | uniq -c
}

# Function: displayOnlyPages
# Purpose: Display only the pages/URLs visited with count
function displayOnlyPages(){
	echo "Pages visited (count | page):"
	cat "$logFile" | cut -d '"' -f 2 | cut -d ' ' -f 2 | sort | uniq -c | sort -rn
}

# Function: histogram
# Purpose: Show daily visit counts per IP address
function histogram(){
	local visitsPerDay=$(cat "$logFile" | cut -d " " -f 4,1 | tr -d '['  | sort \
                              | uniq)
	# This is for debugging, print here to see what it does to continue:
	# echo "$visitsPerDay"

	:> newtemp.txt  # Truncate/create empty file
	echo "$visitsPerDay" | while read -r line;
	do
		local withoutHours=$(echo "$line" | cut -d " " -f 2 \
                                     | cut -d ":" -f 1)
		local IP=$(echo "$line" | cut -d  " " -f 1)

		local newLine="$IP $withoutHours"
		echo "$IP $withoutHours" >> newtemp.txt
	done
	cat "newtemp.txt" | sort -n | uniq -c
}

# Function: frequentVisitors
# Purpose: Display only IPs with more than 10 visits per day
function frequentVisitors(){
	echo "Frequent Visitors (>10 visits per day):"
	echo "Count | IP | Date"
	echo "----------------------------"

	local visitsPerDay=$(cat "$logFile" | cut -d " " -f 4,1 | tr -d '[' | sort | uniq)

	:> newtemp.txt

	echo "$visitsPerDay" | while read -r line;
	do
		local withoutHours=$(echo "$line" | cut -d " " -f 2 | cut -d ":" -f 1)
		local IP=$(echo "$line" | cut -d " " -f 1)
		echo "$IP $withoutHours" >> newtemp.txt
	done

	# Filter results where count > 10
	cat "newtemp.txt" | sort -n | uniq -c | awk '$1 > 10 {print $0}'

	# Clean up
	rm -f newtemp.txt
}

# Function: suspiciousVisitors
# Purpose: Identify IPs accessing known attack indicators (IOCs) WITH DETAILS
function suspiciousVisitors(){
	if [ ! -f "ioc.txt" ]; then
		echo "Error: ioc.txt file not found!"
		echo "Please create ioc.txt with indicators of compromise (one per line)."
		echo "Example entries:"
		echo "  /admin/login.php"
		echo "  /.env"
		echo "  /phpmyadmin/"
		return 1
	fi

	echo "Suspicious Visitors (accessing IOC patterns):"
	echo "=========================================="
	echo ""

	# Get unique suspicious IPs
	local suspiciousIPs=$(grep -F -f ioc.txt "$logFile" | cut -d ' ' -f 1 | sort -u)

	if [ -z "$suspiciousIPs" ]; then
		echo "No suspicious activity detected."
		return 0
	fi

	local totalIPs=0
	local totalAttempts=0

	# For each suspicious IP, show what they accessed
	while IFS= read -r ip; do
		((totalIPs++))

		echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
		echo "🚨 IP Address: $ip"
		echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

		# Count total attempts from this IP
		local ipAttempts=$(grep -F "$ip" "$logFile" | grep -F -f ioc.txt | wc -l)
		((totalAttempts += ipAttempts))
		echo "   Total suspicious attempts: $ipAttempts"
		echo ""
		echo "   Attack patterns accessed:"

		# For each IOC pattern, check if this IP accessed it
		while IFS= read -r pattern; do
			local count=$(grep -F "$ip" "$logFile" | grep -F "$pattern" | wc -l)
			if [ "$count" -gt 0 ]; then
				# Show the pattern and count
				echo "      ├─ $pattern → $count time(s)"

				# Show sample timestamp of when it was accessed
				local timestamp=$(grep -F "$ip" "$logFile" | grep -F "$pattern" | head -1 | cut -d '[' -f 2 | cut -d ']' -f 1)
				echo "      │  First seen: $timestamp"
			fi
		done < ioc.txt

		echo ""
	done <<< "$suspiciousIPs"

	echo "=========================================="
	echo "📊 SUMMARY:"
	echo "   Total suspicious IPs: $totalIPs"
	echo "   Total attack attempts: $totalAttempts"
	echo "=========================================="
}

# Function: saveFlaggedUsers
# Purpose: Save current suspicious visitors to flagged_users.txt WITH ATTACK DETAILS
function saveFlaggedUsers(){
	if [ ! -f "ioc.txt" ]; then
		echo "Error: ioc.txt file not found!"
		echo "Cannot identify flagged users without IOC list."
		return 1
	fi

	echo "Saving flagged users to $flaggedUsersFile..."

	# Get current timestamp
	local timestamp=$(date '+%Y-%m-%d %H:%M:%S')

	# Get suspicious IPs
	local suspiciousIPs=$(grep -F -f ioc.txt "$logFile" | cut -d ' ' -f 1 | sort -u)

	if [ -z "$suspiciousIPs" ]; then
		echo "No suspicious IPs to save."
		return 0
	fi

	# For each suspicious IP, save with attack details
	while IFS= read -r ip; do
		# Check if this IP is already in the file
		if [ -f "$flaggedUsersFile" ] && grep -q "^$ip " "$flaggedUsersFile"; then
			echo "IP $ip already in flagged users list"
		else
			# Get the attack patterns this IP accessed
			local patterns=""
			while IFS= read -r pattern; do
				if grep -F "$ip" "$logFile" | grep -qF "$pattern"; then
					if [ -z "$patterns" ]; then
						patterns="$pattern"
					else
						patterns="$patterns,$pattern"
					fi
				fi
			done < ioc.txt

			# Save: IP TIMESTAMP PATTERNS
			echo "$ip $timestamp $patterns" >> "$flaggedUsersFile"
			echo "Added: $ip (flagged on $timestamp)"
			echo "   Patterns: $patterns"
		fi
	done <<< "$suspiciousIPs"

	echo ""
	echo "Flagged users saved to: $flaggedUsersFile"
	echo "Total flagged IPs in database: $(wc -l < "$flaggedUsersFile" 2>/dev/null || echo 0)"
}

# Function: compareRecurrentOffenders
# Purpose: Compare current suspicious visitors with historical flagged users
# Shows which IPs are recurring offenders WITH DETAILED ATTACK INFORMATION
function compareRecurrentOffenders(){
	if [ ! -f "ioc.txt" ]; then
		echo "Error: ioc.txt file not found!"
		echo "Cannot identify suspicious visitors without IOC list."
		return 1
	fi

	if [ ! -f "$flaggedUsersFile" ]; then
		echo "Warning: No historical flagged users file found."
		echo "Run option 8 first to save flagged users, then run this again."
		return 1
	fi

	echo "Analyzing Recurring Offenders..."
	echo "================================"
	echo ""

	# Get current suspicious IPs
	local currentSuspicious=$(grep -F -f ioc.txt "$logFile" | cut -d ' ' -f 1 | sort -u)

	if [ -z "$currentSuspicious" ]; then
		echo "No suspicious activity detected in current logs."
		return 0
	fi

	echo "📋 CURRENT SCAN RESULTS:"
	echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
	local currentCount=0
	while IFS= read -r ip; do
		((currentCount++))
		local accessCount=$(grep -F "$ip" "$logFile" | grep -F -f ioc.txt | wc -l)
		echo ""
		echo "IP: $ip"
		echo "   Total suspicious accesses: $accessCount"
		echo "   Patterns accessed:"

		# Show which patterns this IP accessed
		while IFS= read -r pattern; do
			local count=$(grep -F "$ip" "$logFile" | grep -F "$pattern" | wc -l)
			if [ "$count" -gt 0 ]; then
				echo "      • $pattern ($count times)"
			fi
		done < ioc.txt
	done <<< "$currentSuspicious"
	echo ""

	echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
	echo "🔄 RECURRING OFFENDERS (Previously Flagged):"
	echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

	local recurrentCount=0

	# Check each current suspicious IP against historical database
	while IFS= read -r ip; do
		if grep -q "^$ip " "$flaggedUsersFile"; then
			((recurrentCount++))

			# Get historical info
			local historyLine=$(grep "^$ip " "$flaggedUsersFile" | head -1)
			local firstSeen=$(echo "$historyLine" | cut -d ' ' -f 2,3)
			local oldPatterns=$(echo "$historyLine" | cut -d ' ' -f 4-)

			# Get current info
			local currentAccess=$(grep -F "$ip" "$logFile" | grep -F -f ioc.txt | wc -l)

			echo ""
			echo "⚠️  $ip (REPEAT OFFENDER)"
			echo "   ├─ First flagged: $firstSeen"
			echo "   ├─ Previous patterns: $oldPatterns"
			echo "   ├─ Current suspicious accesses: $currentAccess"
			echo "   └─ Current patterns:"

			# Show current patterns
			while IFS= read -r pattern; do
				local count=$(grep -F "$ip" "$logFile" | grep -F "$pattern" | wc -l)
				if [ "$count" -gt 0 ]; then
					# Check if this is a NEW pattern (wasn't in old patterns)
					if ! echo "$oldPatterns" | grep -qF "$pattern"; then
						echo "      • $pattern ($count times) 🆕 NEW PATTERN!"
					else
						echo "      • $pattern ($count times)"
					fi
				fi
			done < ioc.txt
		fi
	done <<< "$currentSuspicious"

	if [ $recurrentCount -eq 0 ]; then
		echo ""
		echo "✓ No recurring offenders detected."
		echo "All suspicious IPs are first-time offenders."
	fi

	echo ""
	echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
	echo "📊 SUMMARY:"
	echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
	echo "   Total IPs in current scan: $currentCount"
	echo "   Recurring offenders: $recurrentCount"

	if [ $recurrentCount -gt 0 ]; then
		echo ""
		echo "   ⚠️  WARNING: $recurrentCount IP(s) flagged multiple times!"
		echo "   These IPs show persistent malicious behavior."
		echo "   RECOMMENDED ACTION: Block these IPs at firewall level."

		echo ""
		echo "   🛡️  Suggested firewall commands:"
		while IFS= read -r ip; do
			if grep -q "^$ip " "$flaggedUsersFile"; then
				echo "      sudo iptables -A INPUT -s $ip -j DROP"
			fi
		done <<< "$currentSuspicious"
	else
		echo ""
		echo "   ✓ All suspicious activity is from new IPs."
		echo "   Continue monitoring for patterns."
	fi
	echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

# Main menu loop
while :
do
	echo ""
	echo "======================================"
	echo "  Apache Log Analysis Menu"
	echo "======================================"
	echo "[1] Display all Logs"
	echo "[2] Display only IPs"
	echo "[3] Display only pages visited"
	echo "[4] Histogram (Daily visits per IP)"
	echo "[5] Frequent Visitors (>10 visits)"
	echo "[6] Suspicious Visitors (IOC matches)"
	echo "[7] Quit"
	echo ""
	echo "--- Enhanced Features (with Details) ---"
	echo "[8] Save Flagged Users to Database"
	echo "[9] Compare Recurring Offenders"
	echo "======================================"
	echo -n "Select an option: "

	read userInput
	echo ""

	if [[ "$userInput" == "7" ]]; then
		echo "Goodbye!"
		break

	elif [[ "$userInput" == "1" ]]; then
		echo "Displaying all logs:"
		echo "----------------------------"
		displayAllLogs

	elif [[ "$userInput" == "2" ]]; then
		echo "Displaying only IPs:"
		echo "----------------------------"
		displayOnlyIPs

	elif [[ "$userInput" == "3" ]]; then
		displayOnlyPages

	elif [[ "$userInput" == "4" ]]; then
		echo "Histogram (Daily visits per IP):"
		echo "----------------------------"
		histogram

	elif [[ "$userInput" == "5" ]]; then
		frequentVisitors

	elif [[ "$userInput" == "6" ]]; then
		suspiciousVisitors

	elif [[ "$userInput" == "8" ]]; then
		echo "Option 8: Save Flagged Users"
		echo "----------------------------"
		saveFlaggedUsers

	elif [[ "$userInput" == "9" ]]; then
		echo "Option 9: Compare Recurring Offenders"
		echo "----------------------------"
		compareRecurrentOffenders

	else
		echo "❌ Invalid option: '$userInput'"
		echo "Please select a valid menu item (1-9)."
	fi
done


