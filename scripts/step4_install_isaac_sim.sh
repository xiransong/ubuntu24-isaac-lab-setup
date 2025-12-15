#!/usr/bin/env bash
set -e

echo "=================================================="
echo "Step 4: Install NVIDIA Isaac Sim (Python 3.11)"
echo "=================================================="

# --------------------------------------------------
# 0. Sanity checks
# --------------------------------------------------
echo "[Check] Python 3.11 availability..."
if ! command -v python3.11 >/dev/null 2>&1; then
    echo "ERROR: python3.11 not found."
    echo "Please run step1_install_python311.sh first."
    exit 1
fi
echo "✓ python3.11 found"
echo

# --------------------------------------------------
# 1. Create Python virtual environment
# --------------------------------------------------
ENV_ROOT="$HOME/scratch/env"
ENV_NAME="isaaclab"
ENV_PATH="${ENV_ROOT}/${ENV_NAME}"

echo "[Step] Creating virtual environment at:"
echo "       ${ENV_PATH}"

mkdir -p "${ENV_ROOT}"

if [ ! -d "${ENV_PATH}" ]; then
    python3.11 -m venv "${ENV_PATH}"
    echo "✓ Virtual environment created"
else
    echo "[Info] Virtual environment already exists"
fi
echo

# --------------------------------------------------
# 2. Activate virtual environment
# --------------------------------------------------
echo "[Step] Activating virtual environment..."
source "${ENV_PATH}/bin/activate"
echo "✓ Virtual environment activated"
echo

# --------------------------------------------------
# 3. Upgrade pip
# --------------------------------------------------
echo "[Step] Upgrading pip..."
pip install --upgrade pip
echo

# --------------------------------------------------
# 4. Install Isaac Sim
# --------------------------------------------------
ISAACSIM_VERSION="5.1.0"

echo "[Step] Installing Isaac Sim ${ISAACSIM_VERSION}..."
pip install "isaacsim[all,extscache]==${ISAACSIM_VERSION}" \
    --extra-index-url https://pypi.nvidia.com

echo

# --------------------------------------------------
# 5. Verification
# --------------------------------------------------
echo "=================================================="
echo "[Verification]"
echo "=================================================="

OMNI_KIT_ACCEPT_EULA=YES \
OMNI_KIT_DISABLE_TELEMETRY=1 \
python - <<'EOF'
import isaacsim
print("✓ Isaac Sim imported successfully")
EOF

echo
echo "=================================================="
echo "Step 4 completed successfully."
echo "Isaac Sim ${ISAACSIM_VERSION} is installed in the Python environment."
echo "=================================================="
