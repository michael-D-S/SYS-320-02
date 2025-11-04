#!/bin/bash

# Script to access web page 20 times using curl

IP_ADDRESS="10.0.17.12"

echo "Starting to access the web page 20 times..."

for i in {1..20}
do
    echo "Access attempt $i:"
    curl http://$IP_ADDRESS
    echo ""
done

echo "Completed 20 access attempts!"
