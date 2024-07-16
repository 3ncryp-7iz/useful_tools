#!/bin/bash

# Function to prompt for wordlist file and verify its existence
wordlist() {
    read -p "Please Enter your wordlist: " wordlist

    if [[ ! -f "$wordlist" ]]; then
        echo "Error: Cannot find the entered wordlist ('$wordlist')"
        exit 1
    else
        echo "Running OS file checks against $wordlist"
    fi
}

# Function to check if a command is installed
check_installed() {
    local file_r=$1
    local result=""

    # Check if the command exists in /usr/bin
    if ls -la /usr/bin/"$file_r" &> /dev/null; then
        result="$file_r: Installed"
    elif rpm -qa | grep -qi "$file_r"; then
        result="$file_r: Installed"
    else
        # Check if the package is available in yum
        if yum list all | grep -qi "$file_r"; then
            result="$file_r: Needs to be installed"
            packages_to_install+=("$file_r")
        else
            # Check if a file containing the keyword exists in the repository
            repo_url="{repo_url}"
            if check_repo_file "$repo_url" "$file_r"; then
                result="$file_r: is present in the repository"
                repo_files+=("$file_r")
            else
                result="$file_r: is not present in content view, OS, or repository"
            fi
        fi
    fi

    echo "$result"
}

# Function to check if a file containing the keyword exists in the repository
check_repo_file() {
    local url=$1
    local keyword=$2
    wget -q -O- "$url" | grep -q "$keyword"
}

# Function to read the wordlist file and process each line
wordlist_read_loop() {
    while IFS= read -r file_r; do
        check_installed "$file_r"
    done < "$wordlist"
}

# Function to prompt user for installation options
prompt_install() {
    echo ""
    echo "========================================================================="
    echo ""
    echo "Would you like to install the missing packages?"
    echo "Please enter one of the following;"
    echo "'y' to download the files one by one"
    echo "'a' to download all files at once"
    echo "'n' to exit"
    read -p "Input: " choice
    case $choice in
        y)
            for pkg in "${packages_to_install[@]}"; do
                read -p "Do you want to install $pkg? (y/n): " install_choice
                if [[ $install_choice == "y" ]]; then
                    sudo yum install -y "${pkg,,}"
                fi
            done
            ;;
        a)
            for pkg in "${packages_to_install[@]}"; do
                sudo yum install -y "${pkg,,}"
            done
            ;;
        n)
            echo "Exiting"
            echo ""
            ;;
        *)
            echo "No valid option selected. Exiting."
            echo ""
            ;;
    esac
}

# Main script execution
packages_to_install=()
repo_files=()
wordlist
wordlist_read_loop

if [[ ${#packages_to_install[@]} -gt 0 ]]; then
    prompt_install
else
    echo "All packages are already installed."
fi

if [[ ${#repo_files[@]} -gt 0 ]]; then
    echo "The following files are present in the repository:"
    for file in "${repo_files[@]}"; do
        echo "$file"
    done
fi
