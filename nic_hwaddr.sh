#!/bin/bash

# Define color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Function to update HWADDR in the specified ifcfg file
update_hwaddr() {
  local ifcfg_file=$1
  local mac=$2
  if grep -q "^HWADDR=" "$ifcfg_file"; then
    echo -e "${RED}HWADDR already exists in $ifcfg_file, not modifying.${NC}"
  else
    echo "HWADDR=$mac" >> "$ifcfg_file"
    echo -e "${GREEN}Added HWADDR=$mac to $ifcfg_file${NC}"
  fi
}

# Function to get the permanent MAC address using ethtool
get_mac_address() {
  local nic=$1
  local permaddr=$(ethtool -P "$nic" 2>/dev/null | awk '{print $3}')
  echo "$permaddr"
}

# Function to display NICs and MAC addresses in sorted order
display_nics() {
  echo -e "${BLUE}Listing all NICs and their MAC addresses:${NC}"
  for nic in $(printf "%s\n" "${!nic_mac_map[@]}" | sort); do
    mac=${nic_mac_map[$nic]}
    ifcfg_file="/etc/sysconfig/network-scripts/ifcfg-$nic"
    echo -e "NIC: ${CYAN}$nic${NC}, MAC: ${GREEN}$mac${NC}, ifcfg file: ${YELLOW}$ifcfg_file${NC}"
  done
}

# Store NICs and MAC addresses in an associative array
declare -A nic_mac_map
while IFS= read -r nic; do
  mac=$(get_mac_address "$nic")
  nic_mac_map["$nic"]="$mac"
done < <(sfboot -l | awk '/^  / {print $1}')

# Remove duplicate MAC addresses
declare -A unique_mac_map
for nic in "${!nic_mac_map[@]}"; do
  mac=${nic_mac_map[$nic]}
  if [[ ! ${unique_mac_map[$mac]+_} ]]; then
    unique_mac_map["$mac"]="$nic"
  else
    unset nic_mac_map["$nic"]
  fi
done

# Display NICs and MAC addresses
display_nics

# Prompt the user if they want to update any ifcfg file
while true; do
  read -rp "Do you wish to update any ifcfg file with a MAC address? (yes/no): " confirm_update
  confirm_update=$(echo "$confirm_update" | tr '[:upper:]' '[:lower:]')  # Convert to lowercase for consistency
  if [[ "$confirm_update" == "yes" || "$confirm_update" == "y" ]]; then
    read -rp "Enter the NIC name you want to update: " nic
    mac=${nic_mac_map[$nic]}
    if [ -z "$mac" ]; then
      echo -e "${RED}NIC $nic not found. Please try again.${NC}"
      continue
    fi
    read -rp "Enter the full path to the ifcfg file to update (default is /etc/sysconfig/network-scripts/ifcfg-$nic): " ifcfg_file
    if [ -z "$ifcfg_file" ]; then
      ifcfg_file="/etc/sysconfig/network-scripts/ifcfg-$nic"
    fi
    if [ -e "$ifcfg_file" ]; then
      update_hwaddr "$ifcfg_file" "$mac"
    else
      echo -e "${RED}The specified ifcfg file does not exist.${NC}"
    fi
  elif [[ "$confirm_update" == "no" || "$confirm_update" == "n" ]]; then
    echo "No updates made. Exiting."
    break
  else
    echo -e "${RED}Invalid input. Please answer yes or no.${NC}"
  fi
done

# Verify that the MAC addresses were added
for nic in $(printf "%s\n" "${!nic_mac_map[@]}" | sort); do
  ifcfg_file="/etc/sysconfig/network-scripts/ifcfg-$nic"
  if [ -e "$ifcfg_file" ]; then
    if grep -q "^HWADDR=" "$ifcfg_file"; then
      echo -e "${GREEN}Verified HWADDR in $ifcfg_file${NC}"
    else
      echo -e "${RED}HWADDR not found in $ifcfg_file${NC}"
    fi
  else
    echo "$ifcfg_file does not exist"
  fi
done
