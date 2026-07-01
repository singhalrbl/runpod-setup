# ============================================================
# RunPod per-session activation  (run EACH session)
#
#   source /workspace/setup_env.sh
#
# Activates the venv and points caches at the persistent volume.
# ============================================================

source /workspace/venv/bin/activate
export HF_HOME=/workspace/.cache/huggingface
export PIP_CACHE_DIR=/workspace/.pip-cache

# Re-register the kernel (registration lives on ephemeral disk, so redo each pod)
python -m ipykernel install --user --name venv --display-name "Python (workspace venv)" 2>/dev/null

echo "Environment active."
echo "  Python: $(which python)"
