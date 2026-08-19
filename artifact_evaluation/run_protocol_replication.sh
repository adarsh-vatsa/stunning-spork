#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
IMAGE_NAME="${POLICY_SUMMARIZER_IMAGE:-policysummarizer-ae}"
OUTPUT_DIR="${POLICY_SUMMARIZER_REPLICATION_DIR:-${ROOT_DIR}/replication_runs/policysummarizer-sample-sweep}"

if ! command -v docker >/dev/null 2>&1; then
  echo "ERROR: Docker is required. Install Docker Desktop or Docker Engine first." >&2
  exit 1
fi

needs_api_key=true
for argument in "$@"; do
  if [[ "${argument}" == "--enumerate-only" || "${argument}" == "--dry-run" ]]; then
    needs_api_key=false
  fi
done
if [[ "${needs_api_key}" == true && -z "${ANTHROPIC_API_KEY:-}" ]]; then
  echo "ERROR: Set ANTHROPIC_API_KEY for the paid LLM-backed replication." >&2
  echo "Use --enumerate-only to exercise sample generation without API calls." >&2
  exit 1
fi

mkdir -p "${OUTPUT_DIR}"

echo "[1/2] Building ${IMAGE_NAME}"
docker build --tag "${IMAGE_NAME}" "${ROOT_DIR}/artifacts"

echo "[2/2] Running the PolicySummarizer sample-size protocol"
docker run --rm \
  --user "$(id -u):$(id -g)" \
  --env HOME=/tmp \
  --env PYTHONDONTWRITEBYTECODE=1 \
  --env ANTHROPIC_API_KEY="${ANTHROPIC_API_KEY:-}" \
  --volume "${ROOT_DIR}:/artifact:ro" \
  --volume "${OUTPUT_DIR}:/results" \
  --workdir /artifact \
  "${IMAGE_NAME}" \
  python artifact_evaluation/run_sample_size_sweep.py \
    --dataset-dir /artifact/Dataset \
    --quacky-path /app/src/quacky.py \
    --output-dir /results \
    "$@"
