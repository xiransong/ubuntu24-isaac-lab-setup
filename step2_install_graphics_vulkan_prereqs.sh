#!/usr/bin/env bash
set -e

echo "=================================================="
echo "Step 2: Install system graphics & Vulkan prerequisites"
echo "=================================================="

# --------------------------------------------------
# 0. OS sanity check
# --------------------------------------------------
echo "[Info] OS release:"
lsb_release -a || cat /etc/os-release
echo

# --------------------------------------------------
# 1. Update package index
# --------------------------------------------------
echo "[Step] Updating apt package index..."
sudo apt update

# --------------------------------------------------
# 2. Install Vulkan loader & tools
# --------------------------------------------------
echo "[Step] Installing Vulkan loader and tools..."
sudo apt install -y \
    libvulkan1 \
    vulkan-tools \
    mesa-vulkan-drivers

# --------------------------------------------------
# 3. Install OpenGL / GLX runtime libraries
# --------------------------------------------------
echo "[Step] Installing OpenGL runtime libraries..."
sudo apt install -y \
    libgl1 \
    libglu1-mesa \
    libglx0 \
    libopengl0

# --------------------------------------------------
# 4. Install X11 / windowing runtime libraries
# (Required even for headless Isaac Sim)
# --------------------------------------------------
echo "[Step] Installing X11 / windowing runtime libraries..."
sudo apt install -y \
    libxt6 \
    libxrender1 \
    libxrandr2 \
    libxinerama1 \
    libxcursor1 \
    libxi6 \
    libxkbcommon0 \
    libxkbcommon-x11-0

# --------------------------------------------------
# 5. Optional but useful utilities (debugging)
# --------------------------------------------------
echo "[Step] Installing optional debugging utilities..."
sudo apt install -y \
    pciutils \
    mesa-utils \
    file

# --------------------------------------------------
# 6. Verification
# --------------------------------------------------
echo
echo "=================================================="
echo "[Verification]"
echo "=================================================="

echo "[Check] Vulkan loader version:"
vulkaninfo --version || echo "vulkaninfo not yet functional (expected before NVIDIA ICD)"

echo
echo "[Check] Vulkan ICD directories:"
ls -la /usr/share/vulkan/icd.d || true
ls -la /etc/vulkan/icd.d || true

echo
echo "[Check] OpenGL libraries:"
ldconfig -p | grep -E "libGLX|libGLU|libOpenGL" | head -n 20 || true

echo
echo "[Check] X11 libraries:"
ldconfig -p | grep libXt.so.6 || true

echo
echo "=================================================="
echo "Step 2 completed."
echo "System graphics + Vulkan prerequisites are installed."
echo "=================================================="
