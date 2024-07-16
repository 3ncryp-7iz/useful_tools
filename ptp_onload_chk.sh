#!/bin/bash

# Define ANSI color escape codes for styling the output
YELLOW='\033[1;33m'
GREEN='\033[1;32m'
RED='\033[1;31m'
CYAN='\033[36m'
NC='\033[0m'  # No Color
ITALIC='\033[3m'
RESET_ITALIC='\033[23m'

# Function to extract and format kernel version for matching with onload-kmod naming convention
format_kernel_version_for_onload() {
    echo $1 | sed -e 's/\(.*\)\..*/\1/'
}

# Checks if there are any updates for the kernel
if yum list updates | grep -q 'kernel.x86_64'; then
    echo -e "${YELLOW}Kernel update available.${NC}"

    # Extracts the new kernel version
    new_kernel_version=$(yum list updates | grep 'kernel.x86_64' | awk '{print $2}')
    formatted_kernel_version=$(format_kernel_version_for_onload "$new_kernel_version")

    # Checks for an available 'onload-kmod' package matching the new kernel version
    onload_package=$(yum list available | grep "onload-kmod.*$formatted_kernel_version" | awk '{print $1}')

    if [ -n "$onload_package" ]; then
        echo -e "${GREEN}Current kernel version: $(uname -r)${NC}"
        echo -e "${CYAN}New kernel version to be upgraded: $new_kernel_version${NC}"
        echo -e "${YELLOW}Matching 'onload-kmod' package available in repos: ${NC}$onload_package"
        echo -e "${GREEN}To install the matching 'onload-kmod' package, run: ${NC}yum install $onload_package"
    else
        echo -e "${GREEN}Current kernel version: $(uname -r)${NC}"
        echo -e "${CYAN}New kernel version to be upgraded: $new_kernel_version${NC}"
        echo -e "${RED}No matching 'onload-kmod' package available for the new kernel version.${NC}"
        echo -e "${ITALIC}Consider checking the repository for the 'onload-kmod' package or contacting your system administrator.${RESET_ITALIC}"
    fi
else
    echo "No kernel update available."
fi
