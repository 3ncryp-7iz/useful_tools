#!/bin/bash

# Ensure sysstat service is running
if ! systemctl is-active --quiet sysstat; then
    echo "Sysstat service is not running. Starting it..."
    sudo systemctl start sysstat
fi

# ANSI color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to convert KB to a human-readable format using awk
convert_kb() {
    local KB=$1
    awk -v kb="$KB" '
    BEGIN {
        if (kb >= 1048576) {
            printf "%.2f GB\n", kb / 1048576
        } else if (kb >= 1024) {
            printf "%.2f MB\n", kb / 1024
        } else {
            printf "%.0f KB\n", kb
        }
    }'
}

# Note to the user
echo "System Resource Usage Report (over the past 24 hours)"
echo "======================================================"
echo ""

# CPU Usage Report
echo -e "${RED}CPU Usage Report${NC}"
sar -u -s 00:00:00 | awk '
/^[0-9]/ {
    cpu_usage = $3 + $4 + $5 + $6
    if (cpu_usage > max_cpu_usage) max_cpu_usage = cpu_usage
}
END {print "Max CPU Usage: " max_cpu_usage "%"}'
echo ""

# Memory Usage Report
echo -e "${GREEN}Memory Usage Report${NC}"
max_free=$(sar -r -s 00:00:00 | awk '$1 ~ /^[0-9]/ {print $4}' | sort -nr | head -1)
max_used=$(sar -r -s 00:00:00 | awk '$1 ~ /^[0-9]/ {print $5}' | sort -nr | head -1)
max_buff_cache=$(sar -r -s 00:00:00 | awk '$1 ~ /^[0-9]/ {print $6}' | sort -nr | head -1)

free=$(convert_kb $max_free)
used=$(convert_kb $max_used)
buff_cache=$(convert_kb $max_buff_cache)

echo "Max Memory Usage: $free free, $used used, $buff_cache buff/cache"
echo ""

# Uptime Report
echo -e "${YELLOW}Uptime Report${NC}"
uptime
echo ""

# Disk Usage Report
echo -e "${BLUE}Disk Usage Report${NC}"
sar -d -s 00:00:00 | awk '
/^[0-9]/ {
    if ($3 > max_busy) max_busy=$3
    if ($5 > max_read) max_read=$5
    if ($6 > max_write) max_write=$6
}
END {print "Max Disk Utilization: " max_busy "% busy, " max_read "MB/s read, " max_write "MB/s write"}'
echo ""

# Network Usage Report
echo -e "${RED}Network Usage Report${NC}"
sar -n DEV -s 00:00:00 | awk '
/^[0-9]/ && $2 ~ /^[a-zA-Z0-9]/ {
    if ($5 > max_rx[$2]) max_rx[$2]=$5
    if ($6 > max_tx[$2]) max_tx[$2]=$6
}
END {
    for (iface in max_rx) {
        print "Max Network Usage - Interface: " iface ", RX bytes/s: " max_rx[iface] ", TX bytes/s: " max_tx[iface]
    }
}'
echo ""

echo "All reports displayed."
