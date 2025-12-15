#!/usr/bin/env bash
set -e

echo "=================================================="
echo "Step 3: NVIDIA driver + Vulkan userspace (Isaac Sim)"
echo "=================================================="

REQUIRED_DRIVER_MAJOR=570

# --------------------------------------------------
# 0. Ensure we are on a GPU VM
# --------------------------------------------------
echo "[Check] Detecting NVIDIA GPU..."
if ! lspci | grep -i nvidia >/dev/null; then
    echo "ERROR: No NVIDIA GPU detected."
    echo "Are you running on a GPU VM?"
    exit 1
fi
echo "✓ NVIDIA GPU detected"
echo

# --------------------------------------------------
# 1. Check existing NVIDIA driver
# --------------------------------------------------
NEED_REBOOT=0
DRIVER_MAJOR_INSTALLED=0

if command -v nvidia-smi >/dev/null 2>&1; then
    DRIVER_VERSION=$(nvidia-smi --query-gpu=driver_version --format=csv,noheader | head -n 1)
    DRIVER_MAJOR_INSTALLED=${DRIVER_VERSION%%.*}

    echo "[Info] Detected NVIDIA driver: ${DRIVER_VERSION}"

    if [ "$DRIVER_MAJOR_INSTALLED" -lt "$REQUIRED_DRIVER_MAJOR" ]; then
        echo "[Info] Driver too old for Isaac Sim (need >= ${REQUIRED_DRIVER_MAJOR})"
        NEED_REBOOT=1
    else
        echo "✓ Driver version is sufficient"
    fi
else
    echo "[Info] NVIDIA driver not installed"
    NEED_REBOOT=1
fi
echo

# --------------------------------------------------
# 2. Install / upgrade NVIDIA driver if needed
# --------------------------------------------------
if [ "$NEED_REBOOT" -eq 1 ]; then
    echo "[Step] Installing NVIDIA driver ${REQUIRED_DRIVER_MAJOR}..."

    echo "[Step] Removing old NVIDIA drivers (if any)..."
    sudo apt remove --purge -y '^nvidia-.*' || true
    sudo apt autoremove -y
    sudo apt autoclean

    echo "[Step] Enabling graphics-drivers PPA..."
    sudo apt update
    sudo apt install -y software-properties-common
    sudo add-apt-repository -y ppa:graphics-drivers/ppa
    sudo apt update

    echo "[Step] Installing NVIDIA driver ${REQUIRED_DRIVER_MAJOR}..."
    sudo apt install -y nvidia-driver-${REQUIRED_DRIVER_MAJOR}

    echo
    echo "=================================================="
    echo "NVIDIA driver installed."
    echo "IMPORTANT: You MUST reboot now."
    echo
    echo "After reboot, re-run this script:"
    echo "  bash step3_install_nvidia_vulkan_userspace.sh"
    echo "=================================================="
    exit 0
fi

echo

# --------------------------------------------------
# 3. Install NVIDIA userspace libraries
# --------------------------------------------------
echo "[Step] Installing NVIDIA userspace libraries..."

sudo apt update
sudo apt install -y \
    libnvidia-gl-${DRIVER_MAJOR_INSTALLED} \
    libnvidia-common-${DRIVER_MAJOR_INSTALLED} \
    nvidia-utils-${DRIVER_MAJOR_INSTALLED}

echo "✓ NVIDIA userspace libraries installed"
echo

# --------------------------------------------------
# 4. Verify NVIDIA GLX library
# --------------------------------------------------
echo "[Check] Verifying NVIDIA GLX library..."
if ! ldconfig -p | grep -q libGLX_nvidia; then
    echo "ERROR: libGLX_nvidia.so not found"
    exit 1
fi
echo "✓ libGLX_nvidia found"
echo

# --------------------------------------------------
# 5. Register NVIDIA Vulkan ICD
# --------------------------------------------------
echo "[Step] Registering NVIDIA Vulkan ICD..."

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
echo "✓ Vulkan ICD registered"
echo

# --------------------------------------------------
# 6. Verification
# --------------------------------------------------
echo "=================================================="
echo "[Verification]"
echo "=================================================="

export VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/nvidia_icd.json

echo "[Check] nvidia-smi:"
nvidia-smi
echo

echo "[Check] Vulkan devices:"
vulkaninfo | egrep -i 'deviceName|driverName|vendorID|GPU id' | head -n 30
echo

echo "[Check] Vulkan entrypoint:"
nm -D /usr/lib/x86_64-linux-gnu/libGLX_nvidia.so.0 | grep vk_icdGetInstanceProcAddr
echo

echo "=================================================="
echo "Step 3 completed successfully."
echo "NVIDIA driver + Vulkan are READY for Isaac Sim."
echo "=================================================="
