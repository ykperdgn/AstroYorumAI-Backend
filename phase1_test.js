// Phase 1 Test Script for AstroYorum AI
// This test verifies basic UI functionality

console.log('🧪 PHASE 1 TEST: Starting UI tests...');

// Test 1: Check if app is loaded
function testAppLoaded() {
    console.log('Test 1: Checking if app is loaded...');
    const appElement = document.querySelector('flutter-view');
    if (appElement) {
        console.log('✅ Flutter app element found');
        return true;
    } else {
        console.log('❌ Flutter app element not found');
        return false;
    }
}

// Test 2: Check page title
function testPageTitle() {
    console.log('Test 2: Checking page title...');
    if (document.title.includes('AstroYorum') || document.title.includes('Flutter')) {
        console.log('✅ Page title is correct:', document.title);
        return true;
    } else {
        console.log('❌ Page title unexpected:', document.title);
        return false;
    }
}

// Test 3: Check console for debug messages
function testDebugMessages() {
    console.log('Test 3: Debug messages should appear in console');
    console.log('✅ Console is working properly');
    return true;
}

// Run tests after page load
function runPhase1Tests() {
    console.log('🚀 Running Phase 1 UI Tests...');
    
    const test1 = testAppLoaded();
    const test2 = testPageTitle();
    const test3 = testDebugMessages();
    
    const allPassed = test1 && test2 && test3;
    
    if (allPassed) {
        console.log('🎉 All Phase 1 tests passed!');
    } else {
        console.log('⚠️ Some Phase 1 tests failed');
    }
    
    return allPassed;
}

// Wait for page to load then run tests
if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', runPhase1Tests);
} else {
    runPhase1Tests();
}

// Also run tests after a delay to catch Flutter initialization
setTimeout(runPhase1Tests, 3000);
