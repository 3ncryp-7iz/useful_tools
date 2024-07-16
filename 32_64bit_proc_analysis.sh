#!/bin/bash

count_32bit=0
count_64bit=0
output_32bit="/tmp/execution_analysis_32bit"
output_64bit="/tmp/execution_analysis_64bit"

for pid in $(ps -e -o pid); do
  exe=$(readlink -f /proc/$pid/exe 2>/dev/null)
  if [ -n "$exe" ]; then
    arch=$(file "$exe" | grep -o -e '32-bit' -e '64-bit')
    # would recommend storing this output into a file to reference. I store it in /tmp/ as i thought it was the most universal place to put temporary data
    echo "PID: $pid, Executable: $exe, Architecture: $arch" > /tmp/executable_anaylsis_output
    if [[ $arch == *"32-bit"* ]]; then
      ((count_32bit++))
      echo "PID: $pid, Executable: $exe, Architecture: $arch" >> "$output_32bit"
    elif [[ $arch == *"64-bit"* ]]; then
      ((count_64bit++))
      echo "PID: $pid, Executable: $exe, Architecture: $arch" >> "$output_64bit"
    fi
  fi
done
if [ $count_32bit -eq 0 ]; then
    echo "No 32-bit processes recorded" >> "$output_32bit"
fi
if [ $count_64bit -eq 0 ]; then
    echo "No 64-bit processes recorded" >> "$output_64bit"
fi
echo "Number of 32-bit processes: $count_32bit"
echo "Number of 64-bit processes: $count_64bit"
