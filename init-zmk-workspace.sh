#!/bin/bash
# Initialize persistent ZMK workspace for faster builds

WORKSPACE_DIR="/home/runner/zmk-workspace"

echo "Initializing ZMK workspace at $WORKSPACE_DIR"
mkdir -p "$WORKSPACE_DIR"
cd "$WORKSPACE_DIR"

# Clone ZMK if not present
if [ ! -d "zmk" ]; then
    echo "Cloning ZMK repository..."
    git clone https://github.com/zmkfirmware/zmk.git
fi

# Initialize West workspace
if [ ! -d ".west" ]; then
    echo "Initializing West workspace..."
    west init -l zmk
fi

# Update all modules
echo "Updating West modules (this will take a few minutes)..."
west update

# Export Zephyr CMake package
echo "Exporting Zephyr CMake package..."
west zephyr-export

# Create timestamp
touch .last_update

# Show workspace info
echo ""
echo "Workspace initialized successfully!"
echo "Location: $WORKSPACE_DIR"
echo "Size: $(du -sh . | cut -f1)"
echo ""
echo "Modules downloaded:"
ls -la modules/