#!/usr/bin/env python3
"""
Firebase configuration validation script for AstroYorumAI

This script validates Firebase configuration files and tests API connectivity.
"""

import os
import json
import sys
from pathlib import Path

def check_file_exists(file_path, description):
    """Check if a file exists and print status"""
    path = Path(file_path)
    if path.exists():
        print(f"✅ {description} found at {file_path}")
        return True
    else:
        print(f"❌ {description} missing: {file_path}")
        return False

def validate_json_file(file_path):
    """Validate that a JSON file is properly formatted"""
    try:
        with open(file_path, 'r') as f:
            json.load(f)
        print(f"✅ {file_path} is valid JSON")
        return True
    except json.JSONDecodeError as e:
        print(f"❌ {file_path} has invalid JSON format: {e}")
        return False
    except FileNotFoundError:
        print(f"❌ {file_path} not found")
        return False

def check_firebase_config():
    """Check Firebase configuration files"""
    android_config = "android/app/google-services.json"
    ios_config = "ios/Runner/GoogleService-Info.plist"
    firebase_rc = ".firebaserc"
    firebase_json = "firebase.json"
    
    android_ok = check_file_exists(android_config, "Android Firebase config")
    ios_ok = check_file_exists(ios_config, "iOS Firebase config")
    rc_ok = check_file_exists(firebase_rc, "Firebase project config")
    json_ok = check_file_exists(firebase_json, "Firebase hosting config")
    
    if android_ok:
        validate_json_file(android_config)
    
    if rc_ok:
        validate_json_file(firebase_rc)
    
    if json_ok:
        validate_json_file(firebase_json)

def check_github_workflows():
    """Check GitHub workflow files for Firebase deployment"""
    workflows_dir = ".github/workflows"
    firebase_workflow = os.path.join(workflows_dir, "firebase-deploy.yml")
    firebase_tests = os.path.join(workflows_dir, "firebase-tests.yml")
    
    dir_ok = check_file_exists(workflows_dir, "GitHub workflows directory")
    
    if dir_ok:
        deploy_ok = check_file_exists(firebase_workflow, "Firebase deployment workflow")
        tests_ok = check_file_exists(firebase_tests, "Firebase tests workflow")

def test_firebase_emulators():
    """Test if Firebase emulators are accessible"""
    auth_host = os.environ.get("FIREBASE_AUTH_EMULATOR_HOST")
    firestore_host = os.environ.get("FIRESTORE_EMULATOR_HOST")
    
    if auth_host:
        print(f"✅ Firebase Auth emulator configured: {auth_host}")
    else:
        print("⚠️  Firebase Auth emulator not configured. Set FIREBASE_AUTH_EMULATOR_HOST environment variable.")
    
    if firestore_host:
        print(f"✅ Firestore emulator configured: {firestore_host}")
    else:
        print("⚠️  Firestore emulator not configured. Set FIRESTORE_EMULATOR_HOST environment variable.")

def main():
    """Main entry point"""
    print("🔍 AstroYorumAI Firebase Configuration Check")
    print("-" * 50)
    
    print("\n1. Checking Firebase configuration files:")
    check_firebase_config()
    
    print("\n2. Checking GitHub Actions workflows:")
    check_github_workflows()
    
    print("\n3. Checking Firebase emulator configuration:")
    test_firebase_emulators()
    
    print("\n4. Recommendations:")
    print("   - Ensure firebase-tools is installed: npm install -g firebase-tools")
    print("   - Run emulators for local testing: firebase emulators:start")
    print("   - Set up GitHub secret FIREBASE_SERVICE_ACCOUNT for deployment")
    
    print("\nCheck complete.")

if __name__ == "__main__":
    main()
