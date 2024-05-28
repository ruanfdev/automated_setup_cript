# Automation Script to streamline local development setup for Windows-based systems

# --- Functions ---

function Install-WithWinget {
    param (
        [string]$PackageName,
        [int]$StepNumber
    )

    Write-Host "Installing $PackageName using WinGet..."
    $packageInfo = winget show $PackageName
    $latestVersion = $packageInfo.Property | Where-Object {$_.Name -eq 'Version'} | Select-Object -ExpandProperty Value
    winget install "$PackageName" -v "$latestVersion" -h -e || (
        Write-Warning "Failed to install $PackageName with WinGet."
        Install-WithChocolatey $PackageName $StepNumber
    )

    Write-Host "$PackageName installation completed successfully!"
}

function Install-WithChocolatey {
    param (
        [string]$PackageName,
        [int]$StepNumber
    )

    # Check if Chocolatey is installed
    if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
        Write-Host "Chocolatey not found. Installing..."
        Set-ExecutionPolicy Bypass -Scope Process -Force
        irm get.chocolatey.org/install.ps1 | iex
    }

    choco install $PackageName -y || (
        Write-Error "Failed to install $PackageName with Chocolatey. Please install manually and restart from step $StepNumber."
        exit 1
    )
}

function PreUpdate {
    Write-Host "Checking for and installing Windows Updates..."
    Install-WithWinget Microsoft.Windows.Update 1
}

function InstallCoreComponents {
    Write-Host "Installing core components..."
    Install-WithWinget Git.Git 2
    InstallNodeJS 3
    InstallPHP 4
}

function InstallNodeJS {
    Write-Host "Installing Node.js & npm..."
    Install-WithWinget OpenJS.NodeJS 3
}

function InstallPHP {
    Write-Host "Installing PHP..."
    Install-WithWinget PHP.PHP 4
}

function InstallComposer {
    Write-Host "Installing Composer..."
    # Download Composer installer
    Invoke-WebRequest -Uri https://getcomposer.org/installer -OutFile composer-setup.php
    # Verify installer hash (add hash verification logic here)
    php composer-setup.php --install-dir=$env:ProgramData\ComposerSetup\bin --filename=composer || (
        Write-Error "Error installing Composer. Fix and rerun from step 5."
        exit 1
    )

    Write-Host "Composer installation completed successfully!"
}

function Cleanup {
    Write-Host "Cleaning up..."
    Remove-Item composer-setup.php
}


# --- Main Script ---

Write-Host "Automated Windows Development Environment Setup"
Write-Host "Choose starting step:"
Write-Host "1. Check for and Install Updates"
Write-Host "2. Install Core Components"
Write-Host "3. Install NodeJS & npm"
Write-Host "4. Install PHP"
Write-Host "5. Install Composer"
Write-Host "6. Cleanup (Only if everything else is done)"

$choice = Read-Host "Enter your choice: "

switch ($choice) {
    1 { PreUpdate }
    2 { InstallCoreComponents }
    3 { InstallNodeJS }
    4 { InstallPHP }
    5 { InstallComposer }
    6 { Cleanup }
    default { Write-Error "Invalid choice." ; exit 1 }
}

Write-Host "Setup completed successfully!"