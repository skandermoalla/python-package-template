# Halt in case of errors. https://gist.github.com/vncsna/64825d5609c146e80de8b1fd623011ca
set -eo pipefail
echo "[TEMPLATE INFO] Running entrypoint.sh"

# If the user sets EPFL_RUNAI=1, call the EPFL setup script.
if [ -n "${EPFL_RUNAI}" ]; then
  echo "[TEMPLATE INFO] Running EPFL Run:ai setup script."
  zsh "${EPFL_RUNAI_SETUP_DIR}"/setup.sh
fi

# W&B login.
# This does not need an internet connection.
if [ -n "${WANDB_API_KEY}" ]; then
  echo "[TEMPLATE INFO] Logging in to W&B."
  wandb login "${WANDB_API_KEY}"
fi

if [ -n "${WANDB_API_KEY_FILE}" ]; then
  echo "[TEMPLATE INFO] Logging in to W&B."
  wandb login "$(cat "${WANDB_API_KEY_FILE}")"
fi

# Install the package in editable mode.
# Also ensures the code is mounted correctly.
if [ -n "${SKIP_INSTALL_PROJECT}" ]; then
  # For debugging.
  echo "[TEMPLATE INFO] Skipping the installation of the project."
else
  echo "[TEMPLATE INFO] Installing the project."
  pip install -e "${PROJECT_DIR}"
  python -c "import ${PACKAGE_NAME}"
fi

# Exec so that the child process receives the OS signals.
# It will be PID 1.
echo "[TEMPLATE INFO] Executing the command" "$@"
exec "$@"
