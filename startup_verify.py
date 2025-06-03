#!/usr/bin/env python3
"""
Startup verification for AstroYorumAI API
Ensures the correct app.py is being loaded
"""
import os
import sys

def verify_startup():
    """Verify that app.py exists and is correct"""
    print("🔍 AstroYorumAI Startup Verification")
    print("=" * 40)
    
    # Check if app.py exists
    if not os.path.exists("app.py"):
        print("❌ ERROR: app.py not found!")
        sys.exit(1)
    
    # Check if simple_api.py exists (it shouldn't)
    if os.path.exists("simple_api.py"):
        print("⚠️  WARNING: simple_api.py still exists!")
        print("   This file should have been deleted.")
    else:
        print("✅ GOOD: simple_api.py correctly removed")
    
    # Check app.py content for version
    try:
        with open("app.py", "r") as f:
            content = f.read()
            if "2.1.2-stable" in content:
                print("✅ GOOD: app.py contains v2.1.2-stable")
            else:
                print("❌ ERROR: app.py missing v2.1.2-stable")
                sys.exit(1)
    except Exception as e:
        print(f"❌ ERROR reading app.py: {e}")
        sys.exit(1)
    
    print("=" * 40)
    print("✅ Startup verification passed!")
    print("🚀 Loading AstroYorumAI API v2.1.2-stable...")

if __name__ == "__main__":
    verify_startup()
