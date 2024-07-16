#!/bin/bash

# Output directory for summary files
output_dir="$(pwd)/sar-output"

# Ensure the output directory exists
mkdir -p "$output_dir"

# Ask the user for the number of days to go back
read -p "Enter the number of days to go back for SAR summarization: " num_days

# Function to calculate average and format it as needed
calculate_average() {
    awk '{sum1+=$1; sum2+=$2; sum3+=$3; sum4+=$4; sum5+=$5; sum6+=$6; sum7+=$7} END {printf "Average:\tall\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\n", sum1/NR, sum2/NR, sum3/NR, sum4/NR, sum5/NR, sum6/NR, sum7/NR}'
}

# Calculate average CPU usage for the specified number of days
echo "CPU Usage Summary:" > "$output_dir/cpu_usage_summary.txt"
for ((i = 0; i < num_days; i++)); do
    sar -u -f /var/log/sa/sa$(date --date="$i days ago" +"%d") | grep -E "^[0-9][0-9]:" >> "$output_dir/cpu_usage_summary.txt"
done
sar -u -f /var/log/sa/sa$(date --date="0 days ago" +"%d") | grep -E "Average:" | awk '{print "Average:\tall\t" $3, $5, $7, $9, $11, $13, $15}' >> "$output_dir/cpu_usage_summary.txt"

# Calculate load averages for the specified number of days
echo -e "\nLoad Average Summary:" > "$output_dir/load_avg_summary.txt"
for ((i = 0; i < num_days; i++)); do
    sar -q -f /var/log/sa/sa$(date --date="$i days ago" +"%d") | grep -E "^[0-9][0-9]:" >> "$output_dir/load_avg_summary.txt"
done
sar -q -f /var/log/sa/sa$(date --date="0 days ago" +"%d") | grep -E "Average:" | awk '{print "Average:\t" $2, $4, $6}' >> "$output_dir/load_avg_summary.txt"

# Calculate average network statistics for the specified number of days
echo -e "\nNetwork Summary:" > "$output_dir/network_summary.txt"
for ((i = 0; i < num_days; i++)); do
    sar -n DEV -f /var/log/sa/sa$(date --date="$i days ago" +"%d") | grep -E "^[0-9][0-9]:" >> "$output_dir/network_summary.txt"
done
sar -n DEV -f /var/log/sa/sa$(date --date="0 days ago" +"%d") | grep -E "Average:" | calculate_average >> "$output_dir/network_summary.txt"

# Calculate average disk statistics for the specified number of days
echo -e "\nDisk Summary:" > "$output_dir/disk_summary.txt"
for ((i = 0; i < num_days; i++)); do
    sar -d -f /var/log/sa/sa$(date --date="$i days ago" +"%d") | grep -E "^[0-9][0-9]:" >> "$output_dir/disk_summary.txt"
done
sar -d -f /var/log/sa/sa$(date --date="0 days ago" +"%d") | grep -E "Average:" | calculate_average >> "$output_dir/disk_summary.txt"

# Calculate average memory statistics for the specified number of days
echo -e "\nMemory Summary:" > "$output_dir/memory_summary.txt"
for ((i = 0; i < num_days; i++)); do
    sar -r -f /var/log/sa/sa$(date --date="$i days ago" +"%d") | grep -E "^[0-9][0-9]:" >> "$output_dir/memory_summary.txt"
done
sar -r -f /var/log/sa/sa$(date --date="0 days ago" +"%d") | grep -E "Average:" | awk '{print "Average:\t" $3, $5, $7, $9, $11, $13}' >> "$output_dir/memory_summary.txt"

echo "Data summarization completed for the last $num_days days."
