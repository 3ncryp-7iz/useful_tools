#I, comical as I am, call this rick_grimes.sh - Its a simple, logging, zombie PID killer that can be used with cron, or manual input to kill any annoying consistently hung proc's. 

#!/bin/bash
# Using a two case identifier will reduce the risk of killing important processes
A="{identifiable keyword}"
B="Z"

pids=$(ps aux | grep "$A" | grep "$B" | awk '{print $2}')

if [ -z "$pids" ]; then
    # Can change the output file, this is just a universal location where logs are stored.
    echo "Nothing to kill -- $(date)" >> /var/log/zombies.txt
else
    for pid in $pids; do
        parent_pid=$(ps -o ppid= -p $pid)
        if [ -n "$parent_pid" ]; then
            echo "Killing Zombie $parent_pid! -- $(date)" >> /var/log/zombies.txt
            kill -9 $parent_pid
        else
            echo "Error:$pid is already a parent variant. Please XC & kill manually. -- $(date)" >> /var/log/zombies.txt
        fi
    done
fi
