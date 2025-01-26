#!/usr/bin/env pwsh

# Warna untuk output
$RED = [Console]::ForegroundColor = 'Red'
$GREEN = [Console]::ForegroundColor = 'Green'
$NC = [Console]::ResetColor()

# exit on error
$ErrorActionPreference = "Stop"

# Detecting OS and Architecture
$OS = (Get-WmiObject -Class Win32_OperatingSystem).OSArchitecture
$ARCH = (Get-WmiObject -Class Win32_Processor).Architecture

# Map architecture names for compatibility
if ($ARCH -eq 9) { $ARCH = "x64" }   # 9 is x64 for Windows
if ($ARCH -eq 5) { $ARCH = "arm64" }  # 5 is ARM for Windows

# Check if curl or wget is available
$HTTP_PROGRAM = ""
if (Get-Command "curl" -ErrorAction SilentlyContinue) {
    Write-Host "Using curl for HTTP Requests."
    $HTTP_PROGRAM = "curl"
}
elseif (Get-Command "wget" -ErrorAction SilentlyContinue) {
    Write-Host "Using wget for HTTP Requests."
    $HTTP_PROGRAM = "wget"
}
else {
    Write-Host "ERROR: Neither Curl nor Wget is installed!" -ForegroundColor Red
    exit 1
}

# Function to download files using curl or wget
function Download-File($url) {
    if ($HTTP_PROGRAM -eq "curl") {
        curl -sL $url -H "Authorization: no" 2>$null
    }
    elseif ($HTTP_PROGRAM -eq "wget") {
        wget -qO - --header="Authorization: no" $url
    }
}

# Function to download relevant files based on OS and architecture
function Download-Things {
    $url = "https://api.github.com/repos/SuperCuber/dotter/releases/latest"
    $response = Download-File $url
    $downloadLinks = $response | Select-String -Pattern '"browser_download_url":' | ForEach-Object { ($_ -split '"')[3] }

    foreach ($line in $downloadLinks) {
        $FILENAME = $line.Split("/")[-1]

        # Skip non-Windows executables
        if ($FILENAME -notmatch "\.exe$" -or $FILENAME -match "completion.exe") {
            continue
        }

        # Guard clauses for OS and architecture matching (only Windows executables)
        if ($OS -ne "64-bit" -or ($ARCH -ne "x64" -and $ARCH -ne "arm64")) {
            continue
        }

        # Proceed with downloading the file and save as 'dotter.exe'
        Write-Host "Downloading '$FILENAME'..."
        Download-File $line | Out-File -FilePath "dotter.exe" -Force
    }

    # Verify if dotter was successfully downloaded
    $dotterVersion = .\dotter --version 2>$null
    if ($dotterVersion) {
        Write-Host "Successfully downloaded $dotterVersion" -ForegroundColor Green
    }
    else {
        Write-Host "ERROR: Couldn't download the dotter update!" -ForegroundColor Red
    }
}

# Start the download process
Download-Things
