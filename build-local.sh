#!/bin/bash
# Local ZMK build script - much faster than GitHub Actions

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}ZMK Local Build Script${NC}"
echo "========================"

# Configuration
WORKSPACE_DIR="$HOME/zmk-workspace"
CONFIG_DIR="$(pwd)/config"
BUILD_DIR="$WORKSPACE_DIR/build"
BOARD="nice_nano_v2"

# Ensure we're in the right directory
if [ ! -f "build.yaml" ]; then
    echo -e "${RED}Error: build.yaml not found. Run this script from your Corne-Config directory.${NC}"
    exit 1
fi

# Create workspace if needed
if [ ! -d "$WORKSPACE_DIR" ]; then
    echo -e "${YELLOW}First time setup - this will take a few minutes...${NC}"
    mkdir -p "$WORKSPACE_DIR"
    cd "$WORKSPACE_DIR"
    
    # Clone ZMK
    git clone https://github.com/zmkfirmware/zmk.git
    west init -l zmk
    west update
    west zephyr-export
    
    touch .last_update
    echo -e "${GREEN}Initial setup complete!${NC}"
fi

cd "$WORKSPACE_DIR"

# Update if needed (older than 7 days)
if [ ! -f ".last_update" ] || [ ! -z "$(find . -maxdepth 1 -name '.last_update' -mtime +7 -print 2>/dev/null)" ]; then
    echo -e "${YELLOW}Updating ZMK modules (older than 7 days)...${NC}"
    west update
    west zephyr-export
    touch .last_update
fi

# Copy latest config
echo "Copying config files..."
rm -rf "$WORKSPACE_DIR/config"
cp -r "$CONFIG_DIR" "$WORKSPACE_DIR/config"

# Build function
build_side() {
    local SHIELD="$1"
    local SNIPPET="$2"
    local OUTPUT_NAME="${SHIELD// /_}-${BOARD}"
    
    echo -e "\n${GREEN}Building $SHIELD...${NC}"
    
    # Prepare build command
    local BUILD_CMD="west build -s zmk/app -b $BOARD -d $BUILD_DIR/$OUTPUT_NAME -- -DSHIELD=\"$SHIELD\""
    
    if [ -n "$SNIPPET" ]; then
        BUILD_CMD="$BUILD_CMD -DSNIPPET=\"$SNIPPET\""
    fi
    
    # Clean and build
    rm -rf "$BUILD_DIR/$OUTPUT_NAME"
    eval $BUILD_CMD
    
    # Copy firmware to output directory
    local OUTPUT_DIR="$(dirname $CONFIG_DIR)/firmware"
    mkdir -p "$OUTPUT_DIR"
    
    if [ -f "$BUILD_DIR/$OUTPUT_NAME/zephyr/zmk.uf2" ]; then
        cp "$BUILD_DIR/$OUTPUT_NAME/zephyr/zmk.uf2" "$OUTPUT_DIR/$OUTPUT_NAME.uf2"
        echo -e "${GREEN}✓ Firmware saved to: firmware/$OUTPUT_NAME.uf2${NC}"
    else
        echo -e "${RED}✗ Build failed for $SHIELD${NC}"
        return 1
    fi
}

# Build both sides
echo -e "\n${YELLOW}Starting builds...${NC}"
START_TIME=$(date +%s)

# Build left with studio support
build_side "corne_left nice_view_adapter nice_view" "studio-rpc-usb-uart"

# Build right
build_side "corne_right nice_view_adapter nice_view" ""

# Calculate build time
END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))

echo -e "\n${GREEN}Build complete in ${DURATION} seconds!${NC}"
echo -e "Firmware files are in the ${GREEN}firmware/${NC} directory"
echo ""
echo "To flash:"
echo "1. Connect keyboard half in bootloader mode (double-tap reset)"
echo "2. Copy the appropriate .uf2 file to the mounted drive"