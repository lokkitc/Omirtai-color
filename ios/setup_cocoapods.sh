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

# Check if CocoaPods is installed
if command -v pod &> /dev/null; then
    echo "CocoaPods is installed. Checking version..."
    pod --version
else
    echo "CocoaPods is not installed."
fi

# Update system gems
echo "Updating system gems..."
sudo gem update --system

# Uninstall all versions of CocoaPods
echo "Uninstalling existing CocoaPods versions..."
sudo gem uninstall cocoapods --all --executables

# Install specific version of CocoaPods
echo "Installing CocoaPods 1.15.2..."
sudo gem install cocoapods -v 1.15.2

# Verify installation
echo "Verifying CocoaPods installation..."
pod --version

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