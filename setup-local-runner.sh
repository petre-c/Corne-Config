#!/bin/bash
# Setup script for GitHub Actions self-hosted runner for ZMK builds

echo "Setting up GitHub Actions self-hosted runner for ZMK builds"

# Create runner directory
RUNNER_DIR="$HOME/actions-runner"
mkdir -p "$RUNNER_DIR"
cd "$RUNNER_DIR"

# Download latest runner
RUNNER_VERSION=$(curl -s https://api.github.com/repos/actions/runner/releases/latest | grep -o '"tag_name": "v[^"]*' | cut -d'"' -f4)
echo "Downloading runner version $RUNNER_VERSION..."

# Detect OS and architecture
OS=$(uname -s | tr '[:upper:]' '[:lower:]')
ARCH=$(uname -m)

if [ "$ARCH" = "x86_64" ]; then
    ARCH="x64"
elif [ "$ARCH" = "aarch64" ]; then
    ARCH="arm64"
fi

# Download runner package
DOWNLOAD_URL="https://github.com/actions/runner/releases/download/$RUNNER_VERSION/actions-runner-$OS-$ARCH-${RUNNER_VERSION#v}.tar.gz"
curl -L "$DOWNLOAD_URL" -o runner.tar.gz

# Extract runner
tar xzf runner.tar.gz
rm runner.tar.gz

# Install ZMK build dependencies
echo "Installing ZMK build dependencies..."
if command -v apt-get &> /dev/null; then
    # Debian/Ubuntu
    sudo apt-get update
    sudo apt-get install -y \
        git \
        wget \
        python3 \
        python3-pip \
        python3-venv \
        ninja-build \
        gperf \
        ccache \
        dfu-util \
        device-tree-compiler \
        libsdl2-dev \
        gcc-multilib \
        g++-multilib \
        cmake
elif command -v brew &> /dev/null; then
    # macOS
    brew install \
        cmake \
        ninja \
        python3 \
        ccache \
        dtc \
        dfu-util \
        gperf
fi

# Install West
pip3 install --user west

# Create persistent ZMK workspace
ZMK_WORKSPACE="$HOME/zmk-workspace"
mkdir -p "$ZMK_WORKSPACE"
cd "$ZMK_WORKSPACE"

# Initialize West workspace if not already done
if [ ! -d ".west" ]; then
    echo "Initializing West workspace..."
    west init -l zmk
    west update
    west zephyr-export
fi

# Install Zephyr SDK
ZEPHYR_SDK_VERSION="0.16.8"
if [ ! -d "$HOME/zephyr-sdk-$ZEPHYR_SDK_VERSION" ]; then
    echo "Installing Zephyr SDK..."
    cd /tmp
    wget "https://github.com/zephyrproject-rtos/sdk-ng/releases/download/v$ZEPHYR_SDK_VERSION/zephyr-sdk-${ZEPHYR_SDK_VERSION}_linux-$(uname -m).tar.xz"
    tar -xvf "zephyr-sdk-${ZEPHYR_SDK_VERSION}_linux-$(uname -m).tar.xz" -C "$HOME"
    cd "$HOME/zephyr-sdk-$ZEPHYR_SDK_VERSION"
    ./setup.sh
fi

echo ""
echo "Runner downloaded to: $RUNNER_DIR"
echo "ZMK workspace created at: $ZMK_WORKSPACE"
echo ""
echo "Next steps:"
echo "1. Go to: https://github.com/petre-c/Corne-Config/settings/actions/runners/new"
echo "2. Run the configuration command from that page in $RUNNER_DIR"
echo "3. Start the runner with: ./run.sh"
echo ""
echo "For a persistent service, run: sudo ./svc.sh install && sudo ./svc.sh start"