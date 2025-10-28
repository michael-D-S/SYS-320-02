#!/bin/bash

# Extract and display only the IP address from ip addr command
# Filters out loopback and extracts just the IP without subnet mask

ip addr | grep "inet " | grep -v "127.0.0.1" | awk '{print $2}' | cut -d'/' -f1
