#!/usr/bin/env bash
set -e

echo "=================================================="
echo "Step 5: Install Isaac Lab"
echo "=================================================="

# --------------------------------------------------
# 0. Sanity checks
# --------------------------------------------------
ENV_PATH="$HOME/scratch/env/isaaclab"

echo "[Check] Isaac Lab virtual environment..."
if [ ! -d "${ENV_PATH}" ]; then
    echo "ERROR: Virtual environment not found at:"
    echo "  ${ENV_PATH}"
    echo "Please run step4_install_isaac_sim.sh first."
    exit 1
fi
echo "✓ Virtual environment found"
echo

# --------------------------------------------------
# 1. Activate virtual environment
# --------------------------------------------------
echo "[Step] Activating virtual environment..."
source "${ENV_PATH}/bin/activate"
echo "✓ Virtual environment activated"
echo

# --------------------------------------------------
# 2. Install system build dependencies
# --------------------------------------------------
echo "[Step] Installing system build dependencies..."
sudo apt update
sudo apt install -y \
    cmake \
    build-essential
echo "✓ Build dependencies installed"
echo

# --------------------------------------------------
# 3. Clone Isaac Lab repository
# --------------------------------------------------
LAB_ROOT="$HOME/scratch/isaaclab-lab"
LAB_REPO="IsaacLab"
LAB_PATH="${LAB_ROOT}/${LAB_REPO}"

echo "[Step] Preparing Isaac Lab workspace:"
echo "       ${LAB_PATH}"

mkdir -p "${LAB_ROOT}"
cd "${LAB_ROOT}"

if [ ! -d "${LAB_REPO}" ]; then
    git clone https://github.com/isaac-sim/IsaacLab.git
    echo "✓ Isaac Lab repository cloned"
else
    echo "[Info] Isaac Lab repository already exists"
fi
echo

cd "${LAB_PATH}"

# --------------------------------------------------
# 4. Install Isaac Lab Python dependencies
# --------------------------------------------------
echo "[Step] Installing Isaac Lab..."
./isaaclab.sh --install
echo

# --------------------------------------------------
# 5. Verification
# --------------------------------------------------
echo "=================================================="
echo "[Verification]"
echo "=================================================="

echo "[Check] Isaac Lab CLI:"
./isaaclab.sh --help | head -n 20
echo

echo "=================================================="
echo "Step 5 completed successfully."
echo "Isaac Lab is installed and ready."
echo "=================================================="
