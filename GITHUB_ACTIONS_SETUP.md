# GitHub Actions Workflow Configuration

This document provides guidance on setting up the required secrets for our GitHub Actions workflows.

## Required Secrets

You need to add these secrets to your GitHub repository settings:

1. **FIREBASE_SERVICE_ACCOUNT**
   - Go to Firebase Console → Project Settings → Service Accounts
   - Click "Generate new private key" and download the JSON file
   - Copy the entire JSON content as the secret value

2. **RAILWAY_TOKEN**
   - Install Railway CLI locally: `npm install -g @railway/cli`
   - Login to Railway: `railway login`
   - Generate a token: `railway login --browserless`
   - Copy the token as the secret value

## How to Add Secrets

1. Go to your GitHub repository
2. Click on "Settings" tab
3. In the left sidebar, click on "Secrets and variables" → "Actions"
4. Click "New repository secret"
5. Add each secret with its correct name and value

## Running Workflows Manually

Some workflows can be triggered manually:

1. Go to "Actions" tab in your GitHub repository
2. Select the workflow you want to run
3. Click "Run workflow" button
4. Select the branch and click "Run workflow"

## Workflow Validation

After setting up secrets, validate that workflows run successfully by:

1. Making a small commit to the main branch
2. Going to "Actions" tab to monitor workflow runs
3. Check for green checkmarks indicating successful runs

For any issues, check the workflow logs in GitHub Actions tab.
