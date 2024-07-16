#!/bin/bash

# Prompt for hostname
print_heading "Step 1: Enter Hostname"
read -p "Enter the hostname: " hostname

# Append the domain based on the hostname. {pre-fix} needs to be manually amended below, along with {domain}
if [[ $hostname == *{pre-fix} ]]; then
  certname="$hostname.{domain}"
# If more than one domain present - do the same again
# else
#  certname="$hostname.{domain}"
fi

# List certificates for the given hostname
print_heading "Step 2: List Certificates"
# This directory can change, adjust depending on config vv
found_certificates=$(sudo /opt/puppetlabs/bin/puppetserver ca list --all | grep "$hostname")

if [[ -z "$found_certificates" ]]; then
  echo "No certificates found for $hostname. Proceeding to Step 4."
else
  echo "$found_certificates"

  # Prompt to clean the certificate
  print_heading "Step 3: Clean Certificate"
  read -p "Do you want to clean the certificate for $hostname? (y/n) " clean_certificate

  if [[ $clean_certificate =~ ^[Yy]$ ]]; then
    sudo /opt/puppetlabs/bin/puppetserver ca clean --certname "$certname"
    echo "Certificate cleaned for $hostname."
  else
    echo "Skipping certificate cleaning."
  fi
fi

# Prompt to remove SSL certs and run Puppet on the client server
print_heading "Step 4: Action Required"
read -p "Please remove SSL certificates and run Puppet on the client server. Press Enter to acknowledge that this has been actioned."

# Sign the certificate for the given hostname
print_heading "Step 5: Sign Certificate"
sudo /opt/puppetlabs/bin/puppetserver ca sign --certname "$certname"
