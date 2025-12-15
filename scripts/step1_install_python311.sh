#!/usr/bin/env bash
set -e

echo "=================================================="
echo "Step 1: Install Python 3.11"
echo "=================================================="

# --------------------------------------------------
# 0. Basic system sanity check
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
# 2. Install prerequisites for adding PPAs
# --------------------------------------------------
echo "[Step] Installing prerequisite packages..."
sudo apt install -y \
    software-properties-common \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

# --------------------------------------------------
# 3. Add deadsnakes PPA (safe for 22.04 and 24.04)
# --------------------------------------------------
echo "[Step] Adding deadsnakes PPA for Python versions..."
sudo add-apt-repository -y ppa:deadsnakes/ppa
sudo apt update

# --------------------------------------------------
# 4. Install Python 3.11 and common modules
# --------------------------------------------------
echo "[Step] Installing Python 3.11..."
sudo apt install -y \
    python3.11 \
    python3.11-venv \
    python3.11-dev \
    python3.11-distutils

# --------------------------------------------------
# 5. (Optional but recommended) Install pip for Python 3.11
# --------------------------------------------------
echo "[Step] Installing pip for Python 3.11..."
curl -sS https://bootstrap.pypa.io/get-pip.py | sudo python3.11

# --------------------------------------------------
# 6. Verification
# --------------------------------------------------
echo
echo "=================================================="
echo "[Verification]"
echo "=================================================="

echo "[Check] python3.11 version:"
python3.11 --version

echo
echo "[Check] pip version (python3.11):"
python3.11 -m pip --version

echo
echo "[Check] Python executable path:"
which python3.11

echo
echo "=================================================="
echo "Step 1 completed successfully!!!!!"
echo "Python 3.11 is now available as 'python3.11'."
echo "=================================================="
