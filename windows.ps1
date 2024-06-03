# Automation Script to streamline local development setup for Windows-based systems

# --- Functions ---
function Install-WithWinget {
    param (
        [string]$PackageName
    )

    Write-Host "Installing $PackageName using WinGet..."
    $packageInfo = winget show $PackageName
    $latestVersion = $packageInfo.Property | Where-Object {$_.Name -eq 'Version'} | Select-Object -ExpandProperty Value
    winget install "$PackageName" -v "$latestVersion" -h -e || (
        Write-Warning "Failed to install $PackageName with WinGet."
        Install-WithChocolatey $PackageName
    )

    Write-Host "$PackageName installation completed successfully!"
}

function Install-WithChocolatey {
    param (
        [string]$PackageName
    )

    # Check if Chocolatey is installed
    if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
        Write-Host "Chocolatey not found. Installing..."
        Set-ExecutionPolicy Bypass -Scope Process -Force
        irm get.chocolatey.org/install.ps1 | iex
    }

    choco install $PackageName -y || (
        Write-Error "Failed to install $PackageName with Chocolatey. Please install manually and rerun script."
        exit 1
    )
}

function PreUpdate {
    Write-Host "Checking for and installing Windows Updates..."
    Install-WithWinget Microsoft.Windows.Update
}

function InstallCoreComponents {
    Write-Host "Installing core components..."
    Install-WithWinget Git.Git
    InstallNodeJS
    InstallPHP
}

function InstallNodeJS {
    Write-Host "Installing Node.js & npm..."
    Install-WithWinget OpenJS.NodeJS
}

function InstallPHP {
    Write-Host "Installing PHP..."
    Install-WithWinget PHP.PHP
}

function InstallComposer {
    Write-Host "Installing Composer..."
    # Download Composer installer
    Invoke-WebRequest -Uri https://getcomposer.org/installer -OutFile composer-setup.php

    # Verify installer hash (you'll still need to add hash verification logic here)
    # For now, we'll assume the installer is valid
    php composer-setup.php --install-dir=$env:ProgramData\ComposerSetup\bin --filename=composer || (
        Write-Error "Error installing Composer. Fix and rerun script."
        exit 1
    )

    Write-Host "Composer installation completed successfully!"
}

function Cleanup {
    Write-Host "Cleaning up..."
    Remove-Item composer-setup.php
}

# --- Main Script ---

PreUpdate
InstallCoreComponents
InstallNodeJS
InstallPHP
InstallComposer
Cleanup

Write-Host "Setup completed successfully!"