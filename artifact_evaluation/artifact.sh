#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
IMAGE_NAME="${POLICY_SUMMARIZER_IMAGE:-policysummarizer-ae}"
OUTPUT_DIR="${POLICY_SUMMARIZER_OUTPUT_DIR:-${ROOT_DIR}/reviewer_outputs}"

usage() {
  cat <<'EOF'
PolicySummarizer ISSRE artifact

Usage: bash artifact_evaluation/artifact.sh [command] [options]

Commands:
  review         Complete API-free Reviewed-badge check
  audit          Recompute statistics from retained results (API-free)
  data-check     Verify checksums in artifact_data/ (API-free)
  sample-check   Generate 100 DFA samples for one policy (API-free)
  web            Launch the local PolicySummarizer web interface
  sample-sweep   Run the paid PolicySummarizer LLM protocol
  z3-baseline    Run the paid Z3+LLM baseline protocol
  release-check  Check README, license, credentials, and DOI status
  shell          Open a shell inside the core artifact container
  help           Show this message

Run without a command for an interactive menu.
EOF
}

require_docker() {
  if ! command -v docker >/dev/null 2>&1; then
    echo "ERROR: Docker is required. Install Docker Desktop or Docker Engine." >&2
    exit 1
  fi
}

build_core() {
  require_docker
  if ! docker image inspect "${IMAGE_NAME}" >/dev/null 2>&1; then
    echo "Building ${IMAGE_NAME}. The first build may take 5-15 minutes."
    docker build --tag "${IMAGE_NAME}" "${ROOT_DIR}/artifacts"
  fi
}

run_core() {
  build_core
  mkdir -p "${OUTPUT_DIR}"
  docker run --rm \
    --user "$(id -u):$(id -g)" \
    --env HOME=/tmp \
    --env PYTHONDONTWRITEBYTECODE=1 \
    --volume "${ROOT_DIR}:/artifact:ro" \
    --volume "${OUTPUT_DIR}:/results" \
    --workdir /artifact \
    "${IMAGE_NAME}" "$@"
}

run_audit() {
  echo "API use: none"
  run_core python artifact_evaluation/verify_retained_results.py
}

run_data_check() {
  echo "API use: none"
  run_core sh -c 'cd /artifact/artifact_data && sha256sum --check --quiet MANIFEST.sha256'
  echo "Artifact data checksums: PASS"
}

run_release_check() {
  echo "API use: none"
  run_core python artifact_evaluation/check_release_readiness.py
}

run_review() {
  echo "API use: none"
  echo "This is the complete fast path for the ISSRE Reviewed badge."
  bash "${ROOT_DIR}/artifact_evaluation/smoke_test.sh"
  run_audit
  run_data_check
  run_release_check
  echo
  echo "ISSRE REVIEWER CHECK: PASS"
}

run_sample_check() {
  echo "API use: none"
  POLICY_SUMMARIZER_REPLICATION_DIR="${OUTPUT_DIR}/sample-check" \
    bash "${ROOT_DIR}/artifact_evaluation/run_protocol_replication.sh" \
      --enumerate-only --sample-sizes 100 --start-from 0 --end-at 0 "$@"
}

run_web() {
  build_core
  echo "Open http://localhost:8000 after the server starts. Press Ctrl-C to stop."
  if [[ -n "${ANTHROPIC_API_KEY:-}" ]]; then
    echo "API use: LLM simplification is enabled and may consume paid credit."
  else
    echo "API use: no key supplied; LLM-backed actions will be unavailable."
  fi
  docker run --rm -it \
    --publish 8000:8000 \
    --env ANTHROPIC_API_KEY="${ANTHROPIC_API_KEY:-}" \
    "${IMAGE_NAME}"
}

run_sample_sweep() {
  echo "API use: PAID. Requires ANTHROPIC_API_KEY, credit/quota, and model access."
  POLICY_SUMMARIZER_REPLICATION_DIR="${OUTPUT_DIR}/sample-sweep" \
    bash "${ROOT_DIR}/artifact_evaluation/run_protocol_replication.sh" "$@"
}

run_z3_baseline() {
  echo "API use: PAID unless --enumerate-only is supplied."
  echo "Paid mode requires ANTHROPIC_API_KEY, credit/quota, and model access."
  POLICY_SUMMARIZER_Z3_DIR="${OUTPUT_DIR}/z3-baseline" \
    bash "${ROOT_DIR}/artifact_evaluation/run_z3_baseline.sh" "$@"
}

run_shell() {
  build_core
  mkdir -p "${OUTPUT_DIR}"
  docker run --rm -it \
    --user "$(id -u):$(id -g)" \
    --env HOME=/tmp \
    --volume "${ROOT_DIR}:/artifact:ro" \
    --volume "${OUTPUT_DIR}:/results" \
    --workdir /artifact \
    --entrypoint sh \
    "${IMAGE_NAME}"
}

dispatch() {
  local command="${1:-help}"
  if [[ $# -gt 0 ]]; then shift; fi
  case "${command}" in
    review) run_review "$@" ;;
    audit) run_audit "$@" ;;
    data-check) run_data_check "$@" ;;
    sample-check) run_sample_check "$@" ;;
    web) run_web "$@" ;;
    sample-sweep) run_sample_sweep "$@" ;;
    z3-baseline) run_z3_baseline "$@" ;;
    release-check) run_release_check "$@" ;;
    shell) run_shell "$@" ;;
    help|-h|--help) usage ;;
    *) echo "Unknown command: ${command}" >&2; usage >&2; return 2 ;;
  esac
}

interactive_menu() {
  while true; do
    cat <<'EOF'

PolicySummarizer ISSRE Artifact
1. Run the complete API-free reviewer check (recommended)
2. Audit retained paper results
3. Verify the consolidated dataset checksums
4. Generate samples for one policy without an API
5. Launch the local web interface
6. Run the paid PolicySummarizer replication
7. Run the paid Z3+LLM baseline replication
8. Check release readiness
9. Open a container shell
0. Exit
EOF
    read -r -p "Choose an option: " choice
    case "${choice}" in
      1) dispatch review ;;
      2) dispatch audit ;;
      3) dispatch data-check ;;
      4) dispatch sample-check ;;
      5) dispatch web ;;
      6) dispatch sample-sweep ;;
      7) dispatch z3-baseline ;;
      8) dispatch release-check ;;
      9) dispatch shell ;;
      0) return 0 ;;
      *) echo "Please choose a number from 0 to 9." ;;
    esac
  done
}

if [[ $# -eq 0 ]]; then
  interactive_menu
else
  dispatch "$@"
fi
