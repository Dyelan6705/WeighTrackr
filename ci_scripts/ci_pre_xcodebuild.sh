#!/bin/sh
# Xcode Cloud pre-build script

# Create Capabilities directory that Xcode expects but doesn't create itself
mkdir -p "/Users/local/Library/Developer/Xcode/UserData/Capabilities"

# Remove corrupted provisioning profile temp files left by previous failed builds
find "/Users/local/Library/Developer/Xcode/UserData/Provisioning Profiles/" \
    -name "*.mobileprovision.sb-*" -delete 2>/dev/null || true
