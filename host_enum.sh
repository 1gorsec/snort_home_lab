#!/bin/bash

# Replace the following with the desired target IP address or range
target="<IP>"

# Replace this with the desired output filename for the scan
output_file="nmap_scans_results.txt"

# Define the array of scan types
scan_types=("-sS" "-sT" "-sA")

# Function to run a ping command on the provided target
function run_ping {
    local target="$1"

    echo "Running ping on $target..."
    ping "$target" -c 5
}

# Function to run an Nmap scan with the provided scan type and output to the specified file
function run_nmap_scan {
    local target="$1"
    local scan_type="$2"
    local output_file="$3"

    echo -e "\nRunning Nmap scan on $target with scan type: $scan_type..."
    sudo nmap "$scan_type" "$target" -p1-3306 -oN "$output_file"
    echo "Scan on $target with scan type: $scan_type completed. Results saved in $output_file"
}

# Execute all Nmap scans and combine the results
echo "Nmap Scan Results for $target" > "$output_file"

# Run the ping command
run_ping "$target"

for scan_type in "${scan_types[@]}"; do
    run_nmap_scan "$target" "$scan_type" "$output_file"
done

echo "All Nmap scans on $target completed. Combined results saved in $output_file"
