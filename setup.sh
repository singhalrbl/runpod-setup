#!/bin/bash
# ============================================================
# RunPod environment setup  (run ONCE per fresh network volume)
#
#   bash /workspace/setup.sh
#
# What it does:
#   - Creates a venv at /workspace/venv that REUSES the base
#     image's torch + CUDA (no giant re-download, no mismatch)
#   - Installs only the lightweight ML/RAG packages
#   - Registers a Jupyter kernel so notebooks can use the venv
#   - Points pip + HuggingFace caches at /workspace (persistent)
# ============================================================

set -e  # stop on first error

VENV="/workspace/venv"

echo ">>> [1/6] Setting cache locations on the persistent volume..."
export PIP_CACHE_DIR=/workspace/.pip-cache
export HF_HOME=/workspace/.cache/huggingface
mkdir -p "$PIP_CACHE_DIR" "$HF_HOME"

echo ">>> [2/6] Creating venv (reusing base image's torch/CUDA)..."
if [ ! -d "$VENV" ]; then
    # --system-site-packages lets the venv SEE the pod's pre-installed
    # torch + CUDA, so we don't reinstall ~2GB of GPU libraries.
    python -m venv "$VENV" --system-site-packages
    echo "    venv created."
else
    echo "    venv already exists, reusing it."
fi

echo ">>> [3/6] Activating venv..."
source "$VENV/bin/activate"

echo ">>> [4/6] Upgrading pip..."
python -m pip install --upgrade pip

echo ">>> [5/6] Installing packages..."
if [ -f "/workspace/requirements.txt" ]; then
    echo "    Found requirements.txt — installing from it."
    python -m pip install -r /workspace/requirements.txt
else
    echo "    No requirements.txt — installing default RAG/ML stack."
    # NOTE: torch is intentionally NOT listed — it comes from the base image.
    python -m pip install \
        ipykernel \
        transformers \
        datasets \
        sentence-transformers \
        langchain-community \
        chromadb
fi

echo ">>> [6/6] Registering Jupyter kernel..."
python -m ipykernel install --user --name venv --display-name "Python (workspace venv)"

echo ""
echo ">>> Verifying..."
echo "    Python:  $(which python)"
python -c "import torch; print('    Torch:  ', torch.__version__, '| CUDA available:', torch.cuda.is_available())" || echo "    (torch check skipped)"

echo ""
echo ">>> DONE. Environment ready."
echo ">>> Next: open your notebook, Select Kernel -> 'Python (workspace venv)'."
