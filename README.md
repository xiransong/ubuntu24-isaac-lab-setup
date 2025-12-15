# Isaac Sim + Isaac Lab Reproducible Setup (Lambda Cloud - Ubuntu 24.04.2 LTS)

This repository provides a **fully reproducible, step-by-step setup** for installing **NVIDIA Isaac Sim 5.1** and **Isaac Lab** on a **Lambda Cloud GPU virtual machine**, using **Ubuntu 24.04.2** and **Python 3.11**.

The setup has been tested end-to-end, including **headless reinforcement learning training**, and is suitable for research in **robotics, reinforcement learning, and embodied AI**.

---

## 1. Goal and Base Environment

### 🎯 Goal

Our goal is to:

* Install **NVIDIA Isaac Sim 5.1** (headless, Vulkan-based)
* Install **Isaac Lab** on top of Isaac Sim
* Enable **GPU-accelerated RL training** (e.g., Ant locomotion)
* Ensure the setup is **clean, reproducible, and beginner-friendly**

At the end of this guide, you will be able to successfully run:

```bash
./isaaclab.sh -p scripts/reinforcement_learning/rsl_rl/train.py \
  --task=Isaac-Ant-v0 \
  --headless \
  --max_iterations 100
```

---

### 🖥️ Base Environment

This guide assumes:

* **Cloud provider**: Lambda Cloud
* **OS**: Ubuntu 24.04.2 LTS
* **GPU**: NVIDIA RTX / A-series GPU (e.g., A6000, A10)
* **Access**: SSH access with `sudo` privileges

> ⚠️ While this guide focuses on Lambda Cloud, the setup should work on any **bare-metal or VM GPU instance** with a compatible NVIDIA driver.

---

## 2. High-Level Installation Overview

We install everything under a single top-level directory:

```text
~/scratch
```

This keeps the system clean and avoids polluting the home directory.

### 📁 Directory Structure

```text
~/scratch
├── env/
│   └── isaaclab/          # Python 3.11 virtual environment
└── isaaclab-lab/
    └── IsaacLab/          # Isaac Lab Git repository
```

* `~/scratch/env/isaaclab`
  Python virtual environment used by **both Isaac Sim and Isaac Lab**

* `~/scratch/isaaclab-lab/IsaacLab`
  Official Isaac Lab repository cloned from GitHub

---

### 🔧 Installation Steps (High-Level)

|   Step | Description                                          |
| -----: | ---------------------------------------------------- |
| Step 1 | Install Python 3.11                                  |
| Step 2 | Install Vulkan, OpenGL, and graphics prerequisites   |
| Step 3 | Install / upgrade NVIDIA driver and Vulkan userspace |
| Step 4 | Install NVIDIA Isaac Sim                             |
| Step 5 | Install Isaac Lab and verify RL training             |

Each step is implemented as a **standalone shell script** and can be rerun safely.

---

## 3. Step-by-Step Installation Guide

### Step 0 - Clone this repository

Clone the repository to any location you prefer (for example, your home directory):

```bash
cd ~
git clone https://github.com/xiransong/ubuntu24-isaac-lab-setup
cd ubuntu24-isaac-lab-setup/scripts
```

> 💡 The installation scripts do not depend on the repository location.
> You can place this repository anywhere.

### Step 1 — Install Python 3.11

```bash
bash step1_install_python311.sh
```

This step:

* Installs Python 3.11 using the `deadsnakes` PPA
* Installs `pip`, `venv`, and development headers

#### ✅ Verification

```bash
python3.11 --version
python3.11 -m pip --version
```

You should see Python **3.11.x**.

---

### Step 2 — Install Vulkan & Graphics Prerequisites

```bash
bash step2_install_graphics_vulkan_prereqs.sh
```

This step installs:

* Vulkan loader (`libvulkan1`)
* Vulkan tools (`vulkaninfo`)
* OpenGL / GLX runtime libraries
* Minimal X11 libraries (required even for headless Isaac Sim)

#### ✅ Verification

```bash
vulkaninfo --version
ldconfig -p | grep libGLX
```

> At this stage, Vulkan may not yet see the NVIDIA GPU — this is expected before Step 3.

---

### Step 3 — Install NVIDIA Driver + Vulkan Userspace

```bash
bash step3_install_nvidia_vulkan_userspace.sh
```

This step:

* Detects the NVIDIA GPU
* Installs or upgrades the NVIDIA driver (≥ 570)
* Registers the NVIDIA Vulkan ICD
* Ensures Vulkan can see the GPU

⚠️ **A reboot may be required.**
If prompted, reboot and re-run the script.

#### ✅ Verification

```bash
nvidia-smi
vulkaninfo | grep "GPU id"
```

You should see your NVIDIA GPU listed in both outputs.

---

### Step 4 — Install NVIDIA Isaac Sim

```bash
bash step4_install_isaac_sim.sh
```

This step:

* Creates a Python 3.11 virtual environment at `~/scratch/env/isaaclab`
* Installs **Isaac Sim 5.1.0** from NVIDIA’s PyPI index

#### ✅ Verification

Activate the environment:

```bash
source ~/scratch/env/isaaclab/bin/activate
```

Run Isaac Sim headlessly:

```bash
isaacsim --no-window
```

* When prompted, enter **`Yes`** to accept the EULA
* After initialization, you should see:

```text
Isaac Sim Full App is loaded.
```

You can safely terminate with `Ctrl+C`.

---

### Step 5 — Install Isaac Lab and Verify RL Training

```bash
bash step5_install_isaac_lab.sh
```

This step:

* Clones the official Isaac Lab repository
* Installs system build dependencies
* Installs Isaac Lab Python dependencies

#### ✅ Verification: Run a Headless RL Task

Activate the environment:

```bash
source ~/scratch/env/isaaclab/bin/activate
```

Navigate to Isaac Lab:

```bash
cd ~/scratch/isaaclab-lab/IsaacLab
```

Run a minimal reinforcement learning training job:

```bash
./isaaclab.sh -p scripts/reinforcement_learning/rsl_rl/train.py \
  --task=Isaac-Ant-v0 \
  --headless \
  --max_iterations 100
```

If successful, you should see training logs similar to:

```text
Learning iteration 99/100
Mean reward: ...
Training time: ...
```

🎉 **Congratulations!**
You now have a fully working, GPU-accelerated Isaac Lab setup.

---

## 4. Notes & Tips

* This setup is **headless** — no display server is required.
* All assets are cached locally after first use.
* Re-running scripts is safe and idempotent in most cases.
* For long-running jobs, consider using `tmux` or `screen`.

---

## 5. License & Acknowledgements

* **Isaac Sim** and **Isaac Lab** are developed by NVIDIA.
* This repository provides **installation scripts only** and does not redistribute NVIDIA software.
