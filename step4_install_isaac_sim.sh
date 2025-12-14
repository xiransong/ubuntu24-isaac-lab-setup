set -e

mkdir -p ~/scratch/env
cd ~/scratch/env

python3.11 -m venv isaaclab

source ~/scratch/env/isaaclab/bin/activate

pip install --upgrade pip

pip install "isaacsim[all,extscache]==5.1.0" --extra-index-url https://pypi.nvidia.com
