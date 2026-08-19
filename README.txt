1. TARGET CATEGORY
==================

Code and Dataset


2. TARGET BADGE
===============

Reviewed (including the prerequisite Available badge)


3. INFO
=======

Accepted paper:
Neurosymbolic Characterization for Reliable Access Control Policy Analysis

ISSRE 2026 submission ID:
The accepted paper title above is the artifact identifier; no paper ID is
required to run the artifact.

Authors:
- Adarsh Vatsa, Stevens Institute of Technology, avatsa@stevens.edu
- Bethel Hall, Stevens Institute of Technology
- William Eiers, Stevens Institute of Technology, weiers@stevens.edu

Artifact DOI:
To be reserved on Zenodo and inserted into this file and CITATION.cff before
the final artifact archive is uploaded.

Source repository:
https://github.com/fractional-distillation/stunning-spork

Optional live demonstration:
https://policysummarizer.xyz/


4. EXPECTED BEHAVIOUR
=====================

PolicySummarizer characterizes the requests allowed by cloud access-control
policies. The included Quacky/ABC backend translates a policy to constraints,
checks satisfiability, counts requests, and extracts formal characterizations.
The repository also contains the PolicySummarizer experiments, retained result
files, LLM policy-comprehension experiments, and the user-study materials.

The Getting Started test is deliberately API-free. It builds the submitted
Docker image and analyzes a bundled satisfiable AWS IAM policy. A successful
run reports the policy as satisfiable, prints the logarithm of the permitted
request count, and ends with:

ARTIFACT SMOKE TEST: PASS


5. ARTIFACT DESCRIPTION
=======================

- artifacts/
  Dockerfile, Quacky source, modified ABC integration, web application, and
  bundled sample policies used for the functional smoke test.
- artifact_data/
  Consolidated copy of the policy inputs, cloud-provider assignments and
  bindings, retained PolicySummarizer and CPCA outputs, mutation records,
  historical CSV/JSON/log data, figures, and user-study archive. SHA-256
  checksums are included in artifact_data/MANIFEST.sha256.
- policysummarizer/
  AWS, Azure, and GCP PolicySummarizer implementations, datasets, retained
  result JSON files, mutation comparison results, and analysis notebook.
- CPCA/
  LLM policy-comprehension experiment runner and retained model outputs.
- Exp-1/, Exp-2/, Exp-3/
  Supporting policy-generation and regex-summarization experiments.
- Exp-4-Zelkova/
  Z3 model-enumeration baseline runner and its focused tests.
- Dataset/
  The 587-policy AWS benchmark input.
- artifact_evaluation/
  Reviewer smoke test, API-free retained-result audit, paper/evidence
  crosswalk, release-hygiene check, and protocol-replication runners.
- policy_summarizer_user_study.zip
  Participant-facing user-study site and coded task-answer data for 41 unique
  participants. The public copy contains no JSONBin credential.

The repository root is licensed under MIT. Source retained from Quacky under
artifacts/ carries its original BSD-style license in artifacts/LICENSE.


6. ENVIRONMENT SETUP
====================

Recommended environment:
- Linux, macOS, or Windows with a working Docker Engine or Docker Desktop
- Docker Engine 24 or newer
- 4 CPU cores
- 8 GB RAM
- 15 GB free disk space
- Internet access for the first image build

The smoke test was verified on macOS using Docker/OrbStack. Docker builds an
Ubuntu 22.04 stage for ABC and a Python 3.12 runtime image, so no host Python,
ABC, MONA, or LLM API key is needed for the Getting Started test.

There are two distinct execution paths:

- Reviewed-badge functionality and retained-data check: local Docker only; no
  API key or paid credit is required.
- Optional fresh LLM experiment runs: require an Anthropic API account,
  ANTHROPIC_API_KEY, sufficient paid API credit/quota, network access, and
  access to the model identifier selected for the run. Provider charges are
  the reviewer's responsibility. The historical model snapshot may no longer
  be available to new API calls.

Clone and enter the artifact:

  git clone https://github.com/fractional-distillation/stunning-spork.git
  cd stunning-spork


7. GETTING STARTED
==================

Start the interactive reviewer console:

  bash artifact_evaluation/artifact.sh

Choose option 1 for the complete API-free Reviewed-badge check. The same check
can be run non-interactively with:

  bash artifact_evaluation/artifact.sh review

The first Docker build normally takes 5-15 minutes, depending on network and
CPU speed. A cached build and the sample analysis take under one minute. The
whole procedure is designed to finish within ISSRE's 30-minute Reviewed-badge
window.

The check performs these steps:
1. Build artifacts/Dockerfile, including ABC, MONA, Quacky, and Python code.
2. Run Quacky inside the container from its required working directory.
3. Analyze artifacts/samples/iam/exp_single/iam_simplest_policy/policy.json.
4. Recompute statistics from the retained result files.
5. Verify every file checksum in artifact_data/.
6. Scan release metadata and the artifact for unfinished fields or credentials.

Expected final line:

  ISSRE REVIEWER CHECK: PASS

Optional web interface:

  docker run --rm -p 8000:8000 policysummarizer-ae

Then open http://localhost:8000. The interface can be viewed without an API
key. LLM-backed simplification requests require an Anthropic API key supplied
at runtime:

  docker run --rm -e ANTHROPIC_API_KEY=your-key -p 8000:8000 policysummarizer-ae

The public deployment at https://policysummarizer.xyz/ is provided for
convenience. It is not required for evaluation and is not a substitute for the
archived Docker image and source.


8. REPRODUCIBILITY NOTES
========================

Reviewers can audit the released, API-free result files through Docker with:

  bash artifact_evaluation/artifact.sh audit

This command verifies dataset sizes, exact-match and mean Jaccard statistics,
mutation outcome counts, directional mutation statistics, the 41-participant
study archive, and the retained CPCA records. It runs inside the artifact
container and makes no network or API calls after the image is built.

The detailed mapping from paper claims to retained evidence is in:

  artifact_evaluation/RESULTS_CROSSWALK.md

The repository also provides an optional fresh run of the paper's five
PolicySummarizer sample sizes (100, 500, 1,000, 1,500, and 2,000 strings). A
one-policy, API-free check of sample generation is:

  bash artifact_evaluation/artifact.sh sample-check

Before paying for a full run, inspect its size without making API calls:

  bash artifact_evaluation/artifact.sh sample-sweep --dry-run

The full five-size run uses 41 policies and five candidates per condition,
which means 1,025 initial LLM calls plus any syntax-repair calls. It can take
many hours and incurs Anthropic API charges. The account must have enough paid
credit and rate-limit quota for the run. It is therefore not part of the
30-minute Reviewed-badge procedure. To run it with an available Anthropic
model:

  export ANTHROPIC_API_KEY="your-key"
  bash artifact_evaluation/artifact.sh sample-sweep \
    --model "your-available-model-id" --resume

The runner stores every generated sample set, candidate regex, parser
diagnostic, selected candidate, token count, model identifier, elapsed time,
and aggregate score under replication_runs/. Because LLM responses are
stochastic and provider model snapshots can change, a fresh paid run validates
the released experimental procedure but is not expected to reproduce prior
responses byte for byte.

The Z3+LLM baseline runner likewise records every enumerated model, candidate,
repair, selected regex, API metadata, and score. It is exposed through:

  bash artifact_evaluation/artifact.sh z3-baseline \
    --model "your-available-model-id" --resume

This is also a paid Anthropic workflow and requires ANTHROPIC_API_KEY,
sufficient API credit/quota, network access, and model access. These optional
fresh runs are separate from the API-free functionality and retained-data
checks used for the requested badges.
