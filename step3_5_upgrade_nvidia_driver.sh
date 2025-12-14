#!/usr/bin/env bash
set -e

echo "=================================================="
echo "Step 3.5: Upgrade NVIDIA driver (Isaac Sim 5.1)"
echo "=================================================="

# --------------------------------------------------
# 0. Sanity check: no running NVIDIA processes
# --------------------------------------------------
echo "[Check] Active NVIDIA processes (should be empty):"
nvidia-smi || true
echo

# --------------------------------------------------
# 1. Remove old NVIDIA drivers (safe cleanup)
# --------------------------------------------------
echo "[Step] Removing old NVIDIA drivers..."
sudo apt remove --purge -y '^nvidia-.*' || true
sudo apt autoremove -y
sudo apt autoclean

# --------------------------------------------------
# 2. Enable graphics drivers PPA
# --------------------------------------------------
echo "[Step] Enabling graphics-drivers PPA..."
sudo apt update
sudo apt install -y software-properties-common
sudo add-apt-repository -y ppa:graphics-drivers/ppa
sudo apt update

# --------------------------------------------------
# 3. Install NVIDIA driver 570 (recommended)
# --------------------------------------------------
echo "[Step] Installing NVIDIA driver 570..."
sudo apt install -y nvidia-driver-570

# --------------------------------------------------
# 4. Reboot required
# --------------------------------------------------
echo
echo "=================================================="
echo "NVIDIA driver upgrade completed."
echo
echo "IMPORTANT: You MUST reboot now."
echo
echo "After reboot, run:"
echo "  nvidia-smi"
echo "to verify driver version >= 535.161"
echo "=================================================="
