#!/bin/bash

# Replace the following with the desired target IP address or range
target="192.168.40.128"

# Replace this with the desired output filename for the scan
output_file="port_enum_results.txt"

# Function to perform an Nmap scan for specific ports and services
function run_nmap_scan {
    local target="$1"
    local ports="$2"
    local output_file="$3"

    echo "Running Nmap scan on $target for ports: $ports..."
    nmap -p "$ports" "$target" -oN "$output_file"
    echo "Scan on $target for ports: $ports completed. Results saved in $output_file"
}

# Function to perform Nmap script scanning for specific ports
function run_nmap_script_scan {
    local target="$1"
    local port="$2"
    local script="$3"
    local output_file="$4"

    echo "Running Nmap script scan on $target:$port using script: $script..."
    nmap -p "$port" --script "$script" "$target" -oN "$output_file"
    echo "Nmap script scan on $target:$port using script: $script completed."
}

# Function to perform Nikto scan on port 80
function run_nikto_scan {
    local target="$1"
    local port="$2"
    local output_file="$3"

    echo "Running Nikto scan on $target:$port..."
    nikto -h "http://$target:$port" -o "$output_file-nikto.txt"
    echo "Nikto scan on $target:$port completed."
}

# Execute the Nmap scans
echo "Nmap Scan Results for $target" > "$output_file"
run_nmap_scan "$target" "21,22,23,25,139,445,80,3306" "$output_file"

# Perform banner grabbing
run_nmap_script_scan "$target" 21 "banner" "$output_file"
run_nmap_script_scan "$target" 22 "ssh2-enum-algos" "$output_file"
run_nmap_script_scan "$target" 23 "banner" "$output_file"
run_nmap_script_scan "$target" 25 "smtp-enum-users" "$output_file"
run_nmap_script_scan "$target" 139 "smb-enum-shares" "$output_file"
run_nmap_script_scan "$target" 445 "smb-enum-shares" "$output_file"
run_nmap_script_scan "$target" 80 "http-enum" "$output_file"
run_nmap_script_scan "$target" 3306 "mysql-enum" "$output_file"

# Perform anonymous login on FTP
function anonymous_login_ftp {
    local target="$1"
    local port="$2"

    echo "Attempting anonymous login on FTP $target:$port..."
    echo -e "anonymous\nanonymous" | ftp -inv "$target" "$port" >> "$output_file"
    echo "FTP anonymous login on $target:$port completed."
}

anonymous_login_ftp "$target" 21

# Perform directory enumeration on port 80 using dirb
function dir_enumeration {
    local target="$1"

    echo "Running dirb to enumerate directories on port 80 of $target..."
    dirb "http://$target/" -o "$output_file-dirb.txt"
    echo "dirb scan on port 80 of $target completed."
}

dir_enumeration "$target"

# Perform enumeration on port 445 using enum4linux
function enum4linux_enumeration {
    local target="$1"

    local port=445  # Define the port number explicitly for enumeration

    echo "Running enum4linux to enumerate port 445 on $target..."
    enum4linux -a "$target" >> "$output_file-enum4linux.txt"
    echo "enum4linux scan on port 445 of $target completed."
}

enum4linux_enumeration "$target"

# Perform Nikto scan on port 80
run_nikto_scan "$target" 80 "$output_file"

echo "Port enumeration for $target completed. All results saved in $output_file"
