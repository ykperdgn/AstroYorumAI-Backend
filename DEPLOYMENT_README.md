# AstroYorumAI Deployment Guide

## GitHub Actions Workflow Status

| Workflow | Badge | Description |
|----------|-------|-------------|
| Tests | ![Flutter Tests](https://github.com/[username]/AstroYorumAI/actions/workflows/test.yml/badge.svg) | Runs Flutter tests |
| CI/CD | ![CI/CD Pipeline](https://github.com/[username]/AstroYorumAI/actions/workflows/ci.yml/badge.svg) | Main CI/CD pipeline |
| Firebase Tests | ![Firebase Tests](https://github.com/[username]/AstroYorumAI/actions/workflows/firebase-tests.yml/badge.svg) | Tests Firebase integration |
| Firebase Deploy | ![Firebase Deploy](https://github.com/[username]/AstroYorumAI/actions/workflows/firebase-deploy.yml/badge.svg) | Deploys to Firebase hosting |

## Backend Services

### Deploy to Railway
1. Ensure `RAILWAY_TOKEN` secret is set in GitHub repository settings
2. Trigger deployment via workflow dispatch or commit with "deploy-backend" in the message
3. Verify deployment at the provided Railway URL

### Verify API with:
```bash
python comprehensive_api_test.py
```

## Web Deployment with Firebase

### Steps:
1. Build web app: `flutter build web --release`
2. Deploy to Firebase: `firebase deploy --only hosting`
3. Alternatively, use GitHub Actions workflow which does both automatically

## Troubleshooting Common Issues

### Firebase Deployment Fails
- Verify `FIREBASE_SERVICE_ACCOUNT` secret is set
- Check Firebase project configuration in `.firebaserc`
- Run Firebase deploy locally to see detailed errors

### API Not Available
- Check Render dashboard for deployment status
- Verify that the correct app.py version is being used
- Test API endpoints locally before deployment

### GitHub Actions Workflow Failures
- Check test output for specific test failures
- Verify all required secrets are properly configured
- Try running problematic workflows manually via workflow_dispatch

## Setting Up GitHub Secrets
See [GITHUB_ACTIONS_SETUP.md](GITHUB_ACTIONS_SETUP.md) for detailed instructions on configuring repository secrets needed by workflows.
