#!/bin/bash

# Script to reliably setup CocoaPods for iOS build
echo "Setting up CocoaPods..."

# Navigate to iOS directory
cd ios

# Clean up any existing CocoaPods setup
echo "Cleaning up existing CocoaPods setup..."
rm -f Podfile.lock
rm -rf Pods/
rm -rf ~/.cocoapods/

# Check current Ruby version
echo "Checking Ruby version..."
ruby_version=$(ruby -v)
echo "Current Ruby version: $ruby_version"

# Try to use a compatible version of Ruby if available
# First, try to use rbenv to switch to a compatible version
if command -v rbenv &> /dev/null; then
    echo "rbenv found, checking for compatible Ruby versions..."
    # List available Ruby versions
    rbenv versions
    
    # Try to use Ruby 3.0 if available (it's already being used according to the logs)
    # Check if we can install a newer version
    echo "Attempting to install compatible Ruby version..."
    # Skip Ruby installation for now as it's complex in CI environment
    
    # Try to work with current Ruby version but use older CocoaPods version
    echo "Will try to install compatible CocoaPods version for current Ruby..."
fi

# Uninstall all versions of CocoaPods
echo "Uninstalling existing CocoaPods versions..."
sudo gem uninstall cocoapods --all --executables

# Install a version of CocoaPods that's compatible with Ruby 2.6
echo "Installing CocoaPods version compatible with Ruby 2.6..."
sudo gem install cocoapods -v 1.11.3

# Verify installation
echo "Verifying CocoaPods installation..."
if command -v pod &> /dev/null; then
    pod_version=$(pod --version)
    echo "CocoaPods version installed: $pod_version"
else
    echo "ERROR: CocoaPods installation failed!"
    exit 1
fi

# Setup CocoaPods master repo
echo "Setting up CocoaPods master repo..."
pod setup

# Wait a moment for setup to complete
sleep 10

# Install dependencies
echo "Installing pod dependencies..."
pod install --repo-update

# Verify installation
if [ -d "Pods" ]; then
    echo "CocoaPods installation successful!"
    ls -la Pods/ | head -10
else
    echo "ERROR: CocoaPods installation failed!"
    exit 1
fi

# Go back to root directory
cd ..

echo "CocoaPods setup completed!"