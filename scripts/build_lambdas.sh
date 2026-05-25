#!/usr/bin/env bash
# =============================================================================
# build_lambdas.sh
#
# Builds deployment zip packages for both Lambda functions in
# multi-agent-registration-app.
#
# Usage (run from repo root):
#   chmod +x scripts/build_lambdas.sh
#   ./scripts/build_lambdas.sh
#
# Output:
#   multi-agent-registration-app/bedrock-agent/dist/bedrock_agent.zip
#   multi-agent-registration-app/agentcore-worker-email/dist/agentcore_worker_email.zip
# =============================================================================

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP_ROOT="${REPO_ROOT}/multi-agent-registration-app"

# ---------------------------------------------------------------------------
# Helper: build one Lambda zip
#   $1 = service folder (relative to APP_ROOT)
#   $2 = output zip filename (no path)
#   $3 = space-separated list of source files to include
# ---------------------------------------------------------------------------
build_lambda() {
  local service_dir="${APP_ROOT}/$1"
  local zip_name="$2"
  local source_files="$3"

  local dist_dir="${service_dir}/dist"
  local pkg_dir="${dist_dir}/package"
  local zip_path="${dist_dir}/${zip_name}"

  echo ">>> Building ${zip_name} ..."

  # Clean previous build
  rm -rf "${pkg_dir}"
  mkdir -p "${pkg_dir}"

  # Install dependencies targeting Lambda-compatible Linux platform using uv
  if [[ -f "${service_dir}/requirements.txt" ]]; then
    uv pip install \
      -r "${service_dir}/requirements.txt" \
      --target "${pkg_dir}" \
      --python-version 3.10 \
      --quiet
  fi

  # Copy source files
  for f in ${source_files}; do
    cp "${service_dir}/${f}" "${pkg_dir}/"
  done

  # Zip package contents (not the folder itself)
  (cd "${pkg_dir}" && zip -r "${zip_path}" . -x "*.pyc" -x "*/__pycache__/*" > /dev/null)

  echo "    Output: ${zip_path}"
  echo "    Size  : $(du -sh "${zip_path}" | cut -f1)"
}

# ---------------------------------------------------------------------------
# Build bedrock-agent Lambda
# ---------------------------------------------------------------------------
build_lambda \
  "bedrock-agent" \
  "bedrock_agent.zip" \
  "lambda_function.py utils.py"

# ---------------------------------------------------------------------------
# Build agentcore-worker-email Lambda
# ---------------------------------------------------------------------------
build_lambda \
  "agentcore-worker-email" \
  "agentcore_worker_email.zip" \
  "lambda_function.py utils.py"

echo ""
echo "================================================================="
echo "Both Lambda packages built successfully."
echo ""
echo "Run 'terraform apply' in terra-ai-agent/ to deploy."
echo "================================================================="
