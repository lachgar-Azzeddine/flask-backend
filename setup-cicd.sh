#!/bin/bash

# Flask Backend CI/CD Setup Script
# This script helps you configure the necessary secrets and validate your setup

set -e

echo "🚀 Flask Backend CI/CD Setup"
echo "=============================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if gh CLI is installed
if ! command -v gh &> /dev/null; then
    print_error "GitHub CLI (gh) is not installed. Please install it first:"
    echo "  - macOS: brew install gh"
    echo "  - Windows: choco install gh"
    echo "  - Linux: https://github.com/cli/cli/blob/trunk/docs/install_linux.md"
    exit 1
fi

# Check if user is logged in to GitHub
if ! gh auth status &> /dev/null; then
    print_error "You are not logged in to GitHub CLI. Please run: gh auth login"
    exit 1
fi

print_status "GitHub CLI is installed and you are logged in."

# Get repository information
REPO_OWNER=$(gh repo view --json owner --jq .owner.login)
REPO_NAME=$(gh repo view --json name --jq .name)

print_status "Current repository: $REPO_OWNER/$REPO_NAME"

# Prompt for DockerHub credentials
echo ""
echo "📦 DockerHub Configuration"
echo "=========================="
read -p "Enter your DockerHub username: " DOCKER_USERNAME
read -s -p "Enter your DockerHub password/token: " DOCKER_PASSWORD
echo ""

# Prompt for GitOps repository
echo ""
echo "🔄 GitOps Configuration"
echo "======================"
read -p "Enter your GitOps repository (format: owner/repo): " GITOPS_REPO
read -s -p "Enter your GitHub Personal Access Token for GitOps: " GITOPS_TOKEN
echo ""

# Set secrets
print_status "Setting up GitHub secrets..."

gh secret set DOCKER_USERNAME --body "$DOCKER_USERNAME"
gh secret set DOCKER_PASSWORD --body "$DOCKER_PASSWORD"
gh secret set GITOPS_TOKEN --body "$GITOPS_TOKEN"

print_status "Secrets configured successfully!"

# Update workflow file with correct values
print_status "Updating workflow configuration..."

# Check if the workflow file exists
if [ ! -f ".github/workflows/ci-cd.yml" ]; then
    print_error "Workflow file not found. Please ensure .github/workflows/ci-cd.yml exists."
    exit 1
fi

# Update the workflow file
sed -i.bak "s|DOCKER_IMAGE: .*|DOCKER_IMAGE: $DOCKER_USERNAME/flask-backend|" .github/workflows/ci-cd.yml
sed -i.bak "s|GITOPS_REPO: .*|GITOPS_REPO: $GITOPS_REPO|" .github/workflows/ci-cd.yml

print_status "Workflow configuration updated!"

# Validate DockerHub access
echo ""
echo "🔍 Validating DockerHub access..."
if docker login -u "$DOCKER_USERNAME" -p "$DOCKER_PASSWORD" &> /dev/null; then
    print_status "DockerHub login successful!"
    docker logout &> /dev/null
else
    print_warning "DockerHub login failed. Please check your credentials."
fi

# Test build
echo ""
echo "🏗️  Testing Docker build..."
if docker build -t flask-backend:test . &> /dev/null; then
    print_status "Docker build successful!"
    docker rmi flask-backend:test &> /dev/null || true
else
    print_warning "Docker build failed. Please check your Dockerfile."
fi

# Summary
echo ""
echo "✅ Setup Complete!"
echo "=================="
echo "Next steps:"
echo "1. Commit and push your changes to trigger the CI/CD pipeline"
echo "2. Check the Actions tab in your GitHub repository"
echo "3. Configure ArgoCD to monitor your GitOps repository"
echo "4. Set up branch protection rules for the main branch"
echo ""
echo "For more information, see CI-CD-README.md"

# Clean up backup files
rm -f .github/workflows/ci-cd.yml.bak
