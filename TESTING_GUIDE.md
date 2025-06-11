# AstroYorumAI Testing Guide

This document provides guidance on running different types of tests for the AstroYorumAI project.

## 1. Running All Tests Locally

```powershell
flutter test
```

This will run all tests except those that are skipped due to being integration tests.

## 2. Running Tests with Specific Tags

### Firebase Tests Only

```powershell
flutter test --tags=firebase
```

### Exclude Integration Tests

```powershell
flutter test --exclude-tags=integration
```

### Combine Tags

```powershell
flutter test --tags=firebase --exclude-tags=integration
```

## 3. Running Specific Test Files

```powershell
flutter test test/services/auth_service_test.dart
```

## 4. Firebase Emulator Tests

For tests that require Firebase services, you can use the Firebase emulators:

```powershell
# Install Firebase tools
npm install -g firebase-tools

# Start emulators
firebase emulators:start --only auth,firestore

# In a separate terminal, run tests
$env:FIREBASE_AUTH_EMULATOR_HOST="localhost:9099"
$env:FIRESTORE_EMULATOR_HOST="localhost:8080"
flutter test --tags=firebase
```

## 5. API Integration Tests

Some tests require the backend API to be running:

```powershell
# First start the backend API
cd backend
python app.py

# In a separate terminal, run the tests
flutter test test/services/astrology_backend_service_test.dart
```

## 6. Testing in CI Environment

Our GitHub Actions workflows run these tests with specific configurations:

- **PR and Push**: Runs regular tests excluding integration tests
- **Firebase Tests**: Runs specifically Firebase-related tests with emulators
- **Manual Test Run**: Available through workflow_dispatch in GitHub Actions

## 7. Test Output Formats

### Machine-readable JSON (for CI)

```powershell
flutter test --machine > test-results.json
```

### JUnit XML (for test reporting)

```powershell
flutter test --machine | tojunit -o test-results.xml
```
Note: requires the `tojunit` package.

## 8. Test Coverage

```powershell
flutter test --coverage
./coverage_collect.ps1
```

This will generate a coverage report in the `coverage/` directory.

## 9. Common Testing Issues

### "Integration test requires backend server"

Some tests are skipped because they require an actual backend server. To run these tests:

1. Start the backend server
2. Remove the `@Skip` annotation from the test
3. Run the specific test file

### "Firebase connection failed"

For Firebase tests:

1. Ensure Firebase emulators are running
2. Set the environment variables correctly
3. Make sure test configuration is using emulator connection
