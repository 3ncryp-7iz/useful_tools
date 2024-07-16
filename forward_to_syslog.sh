#!/bin/bash

# Define the desired setting
desired_setting="ForwardToSyslog='yes'"

# Check if the desired setting is already present and uncommented
if ! grep -q "^ForwardToSyslog='yes'" /etc/systemd/journald.conf; then
    # Remove any existing uncommented ForwardToSyslog lines
    sed -i '/^ForwardToSyslog=/d' /etc/systemd/journald.conf
    # Add the desired setting
    echo "$desired_setting" >> /etc/systemd/journald.conf
    echo "Added ForwardToSyslog='yes' to /etc/systemd/journald.conf"
else
    echo "ForwardToSyslog='yes' is already set in /etc/systemd/journald.conf"
fi

# Restart systemd-journald to apply changes
sudo systemctl restart systemd-journald
