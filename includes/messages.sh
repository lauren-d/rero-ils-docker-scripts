#!/bin/bash

# Colors and styles

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'
bold=$(tput bold)
normal=$(tput sgr0)

# Display error message and exit
# @param string message.
error() {
  echo -e "${RED}Error${NC} : $1"
}

# Display warning message
# @param string message.
warning() {
  echo -e "${YELLOW}Warning${NC} : $1"
}

# Display success message
# @param string message.
success() {
  echo -e "${GREEN}Success${NC} : $1"
}

# Display info message
# @param string message.
info() {
  echo -e "${BLUE}Info${NC} : $1"
}

ask() {
  read -p "$1"": " val
  echo $val
}

pressanykey() {
  read -n 1 -s -r -p "Press any key to continue or ctrl-c to abort"
  echo " "
}

continue() {
  while true; do
    read -p "$1 Continue ? (y/n)"" " val
    case $val in
      [Yy]*) break ;;
      [Nn]*) exit ;;
    esac
  done
  echo " "
}
