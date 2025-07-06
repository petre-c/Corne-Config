#!/bin/bash
# Fix permissions for GitHub Actions self-hosted runner

echo "Fixing permissions for GitHub Actions runner..."

# Find the runner work directory
RUNNER_DIR="$HOME/actions-runner"
WORK_DIR="$RUNNER_DIR/_work"

if [ -d "$WORK_DIR" ]; then
    echo "Found work directory: $WORK_DIR"
    
    # Fix ownership of the work directory
    echo "Setting ownership to current user..."
    sudo chown -R $USER:$USER "$WORK_DIR"
    
    # Set proper permissions
    echo "Setting permissions..."
    chmod -R 755 "$WORK_DIR"
    
    # Clean up any lock files
    echo "Cleaning up lock files..."
    find "$WORK_DIR" -name "*.lock" -type f -delete 2>/dev/null || true
    
    echo "Permissions fixed!"
else
    echo "Work directory not found at $WORK_DIR"
    echo "Please adjust the RUNNER_DIR variable in this script"
fi

# Also ensure the ZMK workspace has correct permissions
ZMK_WORKSPACE="/home/runner/zmk-workspace"
if [ -d "$ZMK_WORKSPACE" ]; then
    echo "Fixing ZMK workspace permissions..."
    sudo chown -R $USER:$USER "$ZMK_WORKSPACE" 2>/dev/null || true
    chmod -R 755 "$ZMK_WORKSPACE" 2>/dev/null || true
fi

echo "Done!"