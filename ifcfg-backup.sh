#!/bin/bash

# Define color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Function to copy ifcfg files
copy_ifcfg_file() {
  local nic=$1
  local ifcfg_file="/etc/sysconfig/network-scripts/ifcfg-$nic"
  local backup_file="/home/otladmin/ifcfg-$nic.backup"

  if [ -e "$ifcfg_file" ]; then
    cp "$ifcfg_file" "$backup_file"
    echo -e "${GREEN}Copied $ifcfg_file to $backup_file${NC}"
  else
    echo -e "${RED}$ifcfg_file does not exist.${NC}"
  fi
}

# Pull NICs and make copies of their ifcfg files
echo -e "${YELLOW}Creating backups of ifcfg files for NICs listed by sfboot -l:${NC}"
sfboot -l | awk '/^  / {print $1}' | while read -r nic; do
  copy_ifcfg_file "$nic"
done

echo -e "${GREEN}Backup process completed.${NC}"
