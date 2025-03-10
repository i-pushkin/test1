#!/bin/bash

# Function to check if a port is explicitly allowed in iptables rules
function check_iptables_policy_and_port() {
    local port=$1
    # Check if the default policy for INPUT is DROP or REJECT
    default_policy=$(iptables -L INPUT -n --line-numbers | head -n 1 | awk '{print $4}')
    if [[ "$default_policy" == "DROP" || "$default_policy" == "REJECT" ]]; then
        # Check if there's an explicit ACCEPT rule for the port
        iptables -L INPUT -n | grep -E "ACCEPT" | grep -q ":$port "
        return $?
    else
        # If default policy is not DROP or REJECT, check that port is not blocked
        iptables -L INPUT -n | grep -E "REJECT|DROP" | grep -q ":$port "
        if [ $? -eq 0 ]; then
            return 1  # Port is blocked
        else
            return 0  # Port is allowed
        fi
    fi
}

# Function to print messages
function print_message() {
    if [ $1 -eq 0 ]; then
        echo -e "\033[32m[OK]\033[0m $2"  # Green color for success
    else
        echo -e "\033[31m[FAIL]\033[0m $3"  # Red color for failure
        return 1
    fi
}

# Check if Docker is installed
docker --version > /dev/null 2>&1
docker_status=$?
print_message $docker_status "Docker is installed." "Docker not found. Please install Docker."

# Check if Docker Compose is installed
docker-compose --version > /dev/null 2>&1
compose_status=$?
print_message $compose_status "Docker Compose is installed." "Docker Compose not found. Please install Docker Compose."

# Check if sufficient memory is available (at least 32 GB)
required_memory_gb=32

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # For Linux, use free
    total_memory_kb=$(free -k | grep Mem: | awk '{print $2}')
    total_memory_gb=$((total_memory_kb / 1024 / 1024))
elif [[ "$OSTYPE" == "darwin"* ]]; then
    # For macOS, use sysctl
    total_memory_bytes=$(sysctl -n hw.memsize)
    total_memory_gb=$((total_memory_bytes / 1024 / 1024 / 1024))
else
    echo "Operating system is not supported for memory check."
    exit 1
fi

if [ $total_memory_gb -ge $required_memory_gb ]; then
    memory_status=0
else
    memory_status=1
fi
print_message $memory_status "Sufficient memory available ($total_memory_gb ГБ)." "Insufficient memory ($total_memory_gb GB). At least $required_memory_gb GB is required."

# Check if sufficient disk space is available (at least 50 GB)
required_disk_gb=50
current_disk_gb=$(df -k . | tail -1 | awk '{print $4}')
current_disk_gb=$((current_disk_gb / 1024 / 1024))

if [ $current_disk_gb -ge $required_disk_gb ]; then
    disk_status=0
else
    disk_status=1
fi
print_message $disk_status "Sufficient disk space available ($current_disk_gb ГБ)." "Insufficient disk space ($current_disk_gb GB). At least $required_disk_gb GB is required."

# Check if license.key file exists
license_file="./configs/tfss/license.key"
if [ -f "$license_file" ]; then
    license_status=0
else
    license_status=1
fi
print_message $license_status "license.key file is found." "license.key file not found at $license_file."

# Check Docker Hub registry accessibility
curl -s --connect-timeout 5 --head https://registry.hub.docker.com/ > /dev/null
dockerhub_status=$?
print_message $dockerhub_status "Docker Hub is accessible." "Docker Hub is not accessible. Please check your internet connection."

# Check if directories can be created (located one level above the current directory)
base_dir="../data"
dirs_to_create=(
    "$base_dir/api/static"
    "$base_dir/postgres/db"
    "$base_dir/pg-o2n/db"
)

created_dirs=()
create_dirs_status=0

for dir in "${dirs_to_create[@]}"; do
    if [ -d "$dir" ]; then
        # Directory already exists
        print_message 0 "Directory $dir already exists." ""
    else
        # Directory does not exist, try to create
        mkdir -p "$dir" 2>/dev/null
        if [ $? -eq 0 ]; then
            print_message 0 "Directory $dir can be created."
            # Mark directory for deletion after the check
            created_dirs+=("$dir")
        else
            print_message 1 "" "Failed to create directory $dir. Please check your permissions."
            create_dirs_status=1
        fi
    fi
done

# Remove created directories after successful check
if [ $create_dirs_status -eq 0 ]; then
    for dir in "${created_dirs[@]}"; do
        rm -rf "$dir"
    done
fi

# Check if a Docker container can be run (only if Docker Hub is accessible)
if [ $dockerhub_status -eq 0 ]; then
    docker run --rm hello-world > /dev/null 2>&1
    run_status=$?
    print_message $run_status "Docker is able to run containers." "Failed to run Docker container. Please check your Docker setup."
else
    run_status=1
fi

# Ports to check
ports_to_check=(8000 8501 80 5555 9117 9187 9113)
iptables_check_status=0

for port in "${ports_to_check[@]}"; do
    check_iptables_policy_and_port $port
    if [ $? -ne 0 ]; then
        print_message 1 "" "Port $port is not explicitly allowed in iptables. Check failed."
        iptables_check_status=1
    else
        print_message 0 "Port $port is explicitly allowed in iptables." ""
    fi
done

# Final status check and output
if [[ $docker_status -eq 0 && $compose_status -eq 0 && $memory_status -eq 0 && $disk_status -eq 0 && $license_status -eq 0 && $create_dirs_status -eq 0 && $dockerhub_status -eq 0 && $run_status -eq 0 && $iptables_check_status -eq 0 ]]; then
    echo "All checks passed successfully."
else
    echo "One or more checks failed."
fi
