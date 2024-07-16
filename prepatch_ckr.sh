# Define ANSI color escape codes for styling the output for easier user readability
YELLOW='\033[1;33m'
GREEN='\033[1;32m'
RED='\033[1;31m'
CYAN='\033[36m'
NC='\033[0m'  # No Color
ITALIC='\033[3m'
RESET_ITALIC='\033[23m'

echo -e "${YELLOW}Obtaining hardware information${NC}"
if dmidecode | egrep -A3 'VMware' > /dev/null; then
    echo -e "${GREEN}Server is a VM${NC}"
else
    echo -e "${GREEN}Server is a physical host${NC}"
fi

# Report uptime if more than 50 days
days () { uptime | awk '/days?/ {print $3; next}; {print 0}'; }
UPTIME_THRESHOLD=50
if [ $(days) -ge $UPTIME_THRESHOLD ]; then
    echo -e "${RED}uptime greater than 50 days - Sanity reboot recommended${NC}"
fi

echo -e "${YELLOW}Obtaining subscribed content view${NC}"
subscription-manager identity | grep -i library | cut -c 27-42

echo -e "${YELLOW}Verifying Solarflare installation${NC}"
if lspci | grep -i solarflare > /dev/null; then
    echo -e "${GREEN}Solarflare cards installed - Ensure onload updates are correct${NC}"
else
    echo -e "${GREEN}Solarflare cards not installed${NC}"
fi

echo -e "${YELLOW}Checking update count${NC}"
yum check-update | awk 'p;/^$/{p=1}' | grep -c "\."

echo -e "${YELLOW}Checking package updates${NC}"
yum check-update > /tmp/$HOSTNAME-updates.txt
chmod 755 /tmp/$HOSTNAME-updates.txt
echo -e "${CYAN}Update file located at /tmp/$HOSTNAME-updates.txt${NC}"

# Check if kernel updates are available
echo -e "${YELLOW}Verifying kernel updates${NC}"
# Use a temporary file to avoid broken pipe error
yum list updates > /tmp/yum_kernel_updates.txt
if grep -q 'kernel.x86_64' /tmp/yum_kernel_updates.txt; then
    echo -e "${GREEN}Kernel update available.${NC}"

    # Only proceed with checking for 'onload-kmod' package if a kernel update is found
    echo -e "${YELLOW}Checking for 'onload-kmod' package compatibility with the new kernel version${NC}"

    # Extracts the new kernel version
    new_kernel_version=$(grep 'kernel.x86_64' /tmp/yum_kernel_updates.txt | awk '{print $2}')

    # Checks for an available 'onload-kmod' package matching the new kernel version
    onload_package=$(yum list available | grep "onload-kmod.*$new_kernel_version" | awk '{print $1}')

    if [ -n "$onload_package" ]; then
        echo -e "${GREEN}Matching 'onload-kmod' package available in repos: ${NC}$onload_package"
        echo -e "${CYAN}To install the matching 'onload-kmod' package, run: yum install $onload_package${NC}"
    else
        echo -e "${RED}No matching 'onload-kmod' package available for the new kernel version.${NC}"
        echo -e "${ITALIC}Consider checking the repository for the 'onload-kmod' package or contacting your system administrator.${RESET_ITALIC}"
    fi
else
    echo -e "${RED}No kernel updates available. Skipping 'onload-kmod' package check.${NC}"
fi
# Clean up the temporary file
rm /tmp/yum_kernel_updates.txt
