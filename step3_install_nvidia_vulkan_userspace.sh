#!/usr/bin/env bash
set -e

echo "=================================================="
echo "Step 3: Install NVIDIA driver + Vulkan userspace"
echo "=================================================="

# --------------------------------------------------
# 0. Check that we are on a GPU VM
# --------------------------------------------------
echo "[Check] PCI devices (expect NVIDIA GPU):"
lspci | grep -i nvidia || {
    echo "ERROR: No NVIDIA GPU detected. Are you on a GPU VM?"
    exit 1
}
echo

# --------------------------------------------------
# 1. Check if NVIDIA driver is already installed
# --------------------------------------------------
if command -v nvidia-smi >/dev/null 2>&1; then
    echo "[Info] NVIDIA driver already installed."
    nvidia-smi
else
    echo "[Step] NVIDIA driver not found. Installing driver..."

    # ----------------------------------------------
    # 1a. Enable graphics drivers PPA (Ubuntu standard)
    # ----------------------------------------------
    sudo apt update
    sudo apt install -y software-properties-common
    sudo add-apt-repository -y ppa:graphics-drivers/ppa
    sudo apt update

    # ----------------------------------------------
    # 1b. Install recommended NVIDIA driver
    # (Lambda GPUs like A6000 work well with 535+)
    # ----------------------------------------------
    echo "[Step] Installing NVIDIA driver (recommended)..."
    sudo apt install -y nvidia-driver-535

    echo
    echo "=================================================="
    echo "IMPORTANT:"
    echo "A reboot is REQUIRED after installing the NVIDIA driver."
    echo "Please reboot now, then re-run this script."
    echo "=================================================="
    exit 0
fi

echo

# --------------------------------------------------
# 2. Detect NVIDIA driver major version
# --------------------------------------------------
DRIVER_VERSION=$(nvidia-smi --query-gpu=driver_version --format=csv,noheader | head -n 1)
DRIVER_MAJOR=${DRIVER_VERSION%%.*}

echo "[Info] Detected NVIDIA driver version: $DRIVER_VERSION"
echo "[Info] Using driver major version: $DRIVER_MAJOR"
echo

# --------------------------------------------------
# 3. Install NVIDIA userspace libraries (OpenGL + utils)
# --------------------------------------------------
echo "[Step] Installing NVIDIA userspace libraries..."
sudo apt install -y \
    libnvidia-gl-${DRIVER_MAJOR} \
    libnvidia-common-${DRIVER_MAJOR} \
    nvidia-utils-${DRIVER_MAJOR}

# --------------------------------------------------
# 4. Verify NVIDIA GLX library exists
# --------------------------------------------------
echo
echo "[Check] Verifying libGLX_nvidia..."
ldconfig -p | grep libGLX_nvidia || {
    echo "ERROR: libGLX_nvidia.so not found."
    exit 1
}
echo

# --------------------------------------------------
# 5. Register NVIDIA Vulkan ICD
# --------------------------------------------------
echo "[Step] Installing NVIDIA Vulkan ICD..."
sudo mkdir -p /usr/share/vulkan/icd.d

sudo tee /usr/share/vulkan/icd.d/nvidia_icd.json > /dev/null <<'EOF'
{
    "file_format_version": "1.0.1",
    "ICD": {
        "library_path": "libGLX_nvidia.so.0",
        "api_version": "1.3.204"
    }
}
EOF

sudo ldconfig
echo

# --------------------------------------------------
# 6. Verification: Vulkan must see NVIDIA GPU
# --------------------------------------------------
echo "=================================================="
echo "[Verification]"
echo "=================================================="

export VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/nvidia_icd.json

echo "[Check] Vulkan device:"
vulkaninfo | egrep -i 'deviceName|driverName|vendorID|GPU id' | head -n 20

echo
echo "[Check] Vulkan GPU list:"
vulkaninfo | grep "GPU id"

echo
echo "[Check] Vulkan entrypoint:"
nm -D /usr/lib/x86_64-linux-gnu/libGLX_nvidia.so.0 | grep vk_icdGetInstanceProcAddr

echo
echo "=================================================="
echo "Step 3 completed successfully."
echo "If NVIDIA RTX GPU appears above, Vulkan is READY."
echo "=================================================="
