# Flask Backend CI/CD Setup

This repository contains a Flask application with a complete CI/CD pipeline using GitHub Actions, Docker, and GitOps with ArgoCD.

## 🚀 CI/CD Pipeline Overview

### Architecture
1. **Source Code** → GitHub Repository (flask-backend)
2. **CI/CD** → GitHub Actions
3. **Container Registry** → DockerHub
4. **GitOps** → ArgoCD monitors gitops-App repository
5. **Deployment** → Kubernetes cluster

### Pipeline Stages

#### 1. Build and Push (`build-and-push` job)
- Triggers on push to `main` or `develop` branches
- Builds multi-platform Docker image (linux/amd64, linux/arm64)
- Pushes to DockerHub with multiple tags:
  - `latest` (for main branch)
  - `main-<short-sha>` (for specific commits)
  - Branch name for feature branches

#### 2. GitOps Update (`update-gitops` job)
- Only runs for main branch pushes
- Updates the deployment image in the GitOps repository
- Uses SHA-based tags for precise version tracking
- Triggers ArgoCD sync automatically

#### 3. Security Scan (`security-scan` job)
- Runs on pull requests
- Scans Docker images for vulnerabilities using Trivy
- Uploads results to GitHub Security tab

## 🔧 Required GitHub Secrets

Configure these secrets in your GitHub repository settings:

### DockerHub Credentials
```
DOCKER_USERNAME=your-dockerhub-username
DOCKER_PASSWORD=your-dockerhub-password-or-token
```

### GitOps Repository Access
```
GITOPS_TOKEN=your-github-personal-access-token
```

**Note:** The `GITOPS_TOKEN` needs the following permissions:
- `repo` (full repository access)
- `workflow` (if you want to trigger workflows in the GitOps repo)

## 🏗️ Setup Instructions

### Step 1: Fork/Clone Repositories
1. Fork or create `flask-backend` repository
2. Fork or create `gitops-App` repository
3. Ensure the GitOps repository has the correct structure

### Step 2: Configure Secrets
1. Go to your `flask-backend` repository
2. Navigate to Settings → Secrets and variables → Actions
3. Add the required secrets listed above

### Step 3: Update Configuration
Update the environment variables in `.github/workflows/ci-cd.yml`:
```yaml
env:
  DOCKER_IMAGE: your-dockerhub-username/flask-backend
  GITOPS_REPO: your-username/gitops-App
  GITOPS_PATH: apps/flask-app/deployment.yaml
```

### Step 4: Verify GitOps Repository Structure
Ensure your GitOps repository has this structure:
```
gitops-App/
├── apps/
│   └── flask-app/
│       ├── deployment.yaml
│       ├── service.yaml
│       └── kustomization.yaml
└── applications/
    └── multi-app.yaml
```

### Step 5: Configure ArgoCD
1. Install ArgoCD in your Kubernetes cluster
2. Create an Application pointing to your GitOps repository
3. Set up auto-sync for continuous deployment

## 🔄 Workflow Details

### Automatic Triggers
- **Push to main/develop:** Full CI/CD pipeline
- **Pull Request:** Build, test, and security scan
- **Schedule:** Dependency updates (weekly)
- **Schedule:** Health checks (every 30 minutes)

### Manual Triggers
All workflows can be triggered manually using `workflow_dispatch`

### Image Tagging Strategy
- `latest`: Always points to the latest main branch build
- `main-<sha>`: Specific commit on main branch
- `develop-<sha>`: Specific commit on develop branch
- `<branch-name>`: For feature branches

## 🛡️ Security Features

### Docker Security
- Multi-stage builds for smaller images
- Non-root user execution
- Health checks included
- Vulnerability scanning with Trivy

### GitHub Security
- Dependabot for dependency updates
- Security scanning in CI/CD
- Secrets management
- Branch protection recommended

## 📊 Monitoring and Maintenance

### Health Checks
- Automated application health monitoring
- Configurable endpoints and intervals
- Failure notifications (extend as needed)

### Dependency Management
- Automated weekly dependency updates
- Pull request creation for review
- Security vulnerability alerts

## 🚨 Troubleshooting

### Common Issues

1. **Build Failures**
   - Check Docker credentials
   - Verify Dockerfile syntax
   - Review build logs in Actions tab

2. **GitOps Update Failures**
   - Verify GITOPS_TOKEN permissions
   - Check repository names and paths
   - Ensure target file exists

3. **ArgoCD Not Syncing**
   - Check Application configuration
   - Verify repository access
   - Review ArgoCD logs

### Debug Commands
```bash
# Test Docker build locally
docker build -t flask-backend:test .

# Test container locally
docker run -p 5000:5000 flask-backend:test

# Check application health
curl http://localhost:5000/api/message
```

## 🎯 Best Practices

1. **Branch Protection:** Enable branch protection rules for main branch
2. **Required Reviews:** Require pull request reviews before merging
3. **Status Checks:** Make CI/CD checks required for merging
4. **Environment Separation:** Use different clusters for staging/production
5. **Monitoring:** Set up proper monitoring and alerting
6. **Backup:** Regular backups of critical configurations

## 📈 Future Enhancements

- [ ] Add staging environment
- [ ] Implement blue-green deployments
- [ ] Add integration tests
- [ ] Set up monitoring with Prometheus/Grafana
- [ ] Implement rollback mechanisms
- [ ] Add database migrations
- [ ] Configure SSL/TLS certificates
- [ ] Set up log aggregation
