#!/usr/bin/env bash

# Warna
RED='\033[0;31m'   # Merah
GREEN='\033[0;32m' # Hijau
NC='\033[0m'       # No Color (reset ke warna default)

# exit on error
set -e

# Detecting OS and Architecture
OS=$(uname -s | tr '[:upper:]' '[:lower:]') # Convert OS to lowercase
ARCH=$(uname -m)

# Map architecture names for compatibility
if [[ "$ARCH" == "x86_64" ]]; then
    ARCH="x64"
elif [[ "$ARCH" == "aarch64" ]]; then
    ARCH="arm64"
fi

# Check for curl or wget
if curl --version &>/dev/null
then
  echo "Using curl for HTTP Requests."
  HTTP_PROGRAM="curl"
elif wget --version &>/dev/null
then
  echo "Using wget for HTTP requests."
  HTTP_PROGRAM="wget"
else
  >&2 echo "ERROR: Neither Curl nor Wget is installed!"
  exit 1
fi

# Function to download files using curl or wget
function download() {
  case $HTTP_PROGRAM in
    "curl")
      curl -qL $1 -H "Authorization: no" 2>/dev/null
      ;;
    "wget")
      wget -qO - --header="Authorization: no" $1
      ;;
  esac
}

# Function to download relevant files based on OS and architecture
function download_things() {
  download https://api.github.com/repos/SuperCuber/dotter/releases/latest | grep '"browser_download_url":' | cut -d'"' -f4 | while read line;
  do
    FILENAME=$(echo ${line} | rev | cut -d / -f 1 | rev)

    # Skip Windows executables and completion files
    if [[ $FILENAME == *.exe || $FILENAME == completion.zip ]]; then
      continue
    fi

    # Guard clauses for OS and architecture matching
    if [[ "$OS" == "linux" && "$ARCH" == "x64" && "$FILENAME" != *linux-x64-musl* ]]; then
      continue
    fi

    if [[ "$OS" == "linux" && "$ARCH" == "arm64" && "$FILENAME" != *linux-arm64-musl* ]]; then
      continue
    fi

    if [[ "$OS" == "darwin" && "$ARCH" == "arm64" && "$FILENAME" != *macos-arm64* ]]; then
      continue
    fi

    # Proceed with downloading the file and save as 'dotter'
    echo "Downloading \"$FILENAME\"..."
    download ${line} > dotter

    # Add execute permissions for non-Windows files
    if [[ -f "dotter" && $FILENAME != *.exe ]]; then
      echo "Adding EXECUTE permissions to ./dotter"
      chmod +x ./dotter
    fi

    echo "FINISHED downloading \"dotter\""
  done

  # Verify if dotter was successfully downloaded
  DOTTER_VERSION=$(./dotter --version 2>/dev/null)
  if [[ $DOTTER_VERSION != "" ]]; then
    echo "Successfully downloaded $DOTTER_VERSION"
  else
    >&2 echo "ERROR: Couldn't download the dotter update!"
  fi
}

# Start the download process
download_things 2> >(while read -r line; do echo -e "${GREEN}$line${NC}" ; done) \
                 1> >(while read -r line; do echo -e "${GREEN}$line${NC}" ; done)

./dotter
