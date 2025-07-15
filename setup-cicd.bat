@echo off
setlocal enabledelayedexpansion

:: Flask Backend CI/CD Setup Script for Windows
:: This script helps you configure the necessary secrets and validate your setup

echo 🚀 Flask Backend CI/CD Setup
echo ==============================

:: Check if gh CLI is installed
gh --version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] GitHub CLI ^(gh^) is not installed. Please install it first:
    echo   - Windows: choco install gh
    echo   - Or download from: https://github.com/cli/cli/releases
    exit /b 1
)

:: Check if user is logged in to GitHub
gh auth status >nul 2>&1
if errorlevel 1 (
    echo [ERROR] You are not logged in to GitHub CLI. Please run: gh auth login
    exit /b 1
)

echo [INFO] GitHub CLI is installed and you are logged in.

:: Get repository information
for /f "tokens=*" %%i in ('gh repo view --json owner --jq .owner.login') do set REPO_OWNER=%%i
for /f "tokens=*" %%i in ('gh repo view --json name --jq .name') do set REPO_NAME=%%i

echo [INFO] Current repository: %REPO_OWNER%/%REPO_NAME%

:: Prompt for DockerHub credentials
echo.
echo 📦 DockerHub Configuration
echo ==========================
set /p DOCKER_USERNAME="Enter your DockerHub username: "
set /p DOCKER_PASSWORD="Enter your DockerHub password/token: "

:: Prompt for GitOps repository
echo.
echo 🔄 GitOps Configuration
echo ======================
set /p GITOPS_REPO="Enter your GitOps repository (format: owner/repo): "
set /p GITOPS_TOKEN="Enter your GitHub Personal Access Token for GitOps: "

:: Set secrets
echo [INFO] Setting up GitHub secrets...

gh secret set DOCKER_USERNAME --body "%DOCKER_USERNAME%"
gh secret set DOCKER_PASSWORD --body "%DOCKER_PASSWORD%"
gh secret set GITOPS_TOKEN --body "%GITOPS_TOKEN%"

echo [INFO] Secrets configured successfully!

:: Update workflow file with correct values
echo [INFO] Updating workflow configuration...

:: Check if the workflow file exists
if not exist ".github\workflows\ci-cd.yml" (
    echo [ERROR] Workflow file not found. Please ensure .github\workflows\ci-cd.yml exists.
    exit /b 1
)

:: Create a temporary PowerShell script to update the file
echo $content = Get-Content '.github\workflows\ci-cd.yml' > temp_update.ps1
echo $content = $content -replace 'DOCKER_IMAGE: .*', 'DOCKER_IMAGE: %DOCKER_USERNAME%/flask-backend' >> temp_update.ps1
echo $content = $content -replace 'GITOPS_REPO: .*', 'GITOPS_REPO: %GITOPS_REPO%' >> temp_update.ps1
echo $content ^| Set-Content '.github\workflows\ci-cd.yml' >> temp_update.ps1

powershell -ExecutionPolicy Bypass -File temp_update.ps1
del temp_update.ps1

echo [INFO] Workflow configuration updated!

:: Summary
echo.
echo ✅ Setup Complete!
echo ==================
echo Next steps:
echo 1. Commit and push your changes to trigger the CI/CD pipeline
echo 2. Check the Actions tab in your GitHub repository
echo 3. Configure ArgoCD to monitor your GitOps repository
echo 4. Set up branch protection rules for the main branch
echo.
echo For more information, see CI-CD-README.md

pause
