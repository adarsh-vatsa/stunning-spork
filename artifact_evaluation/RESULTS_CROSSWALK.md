# Paper Claims and Retained Evidence

This document maps the accepted paper's quantitative claims to the released
datasets, result records, analysis scripts, and optional experiment runners.

Run the API-free audit with:

```bash
python3 artifact_evaluation/verify_retained_results.py
```

## PolicySummarizer Evaluation

| Claim | Retained evidence | Audit status |
| --- | --- | --- |
| 587 AWS, 100 Azure, and 100 GCP policy records | `policysummarizer/results_aws/`, `policysummarizer/regex_results/`, and `policysummarizer/string_results/` | Recomputed from raw JSON |
| 41 of 587 AWS policies are unsatisfiable, leaving 546 scored policies | Both AWS result files | Recomputed from raw JSON |
| Direct exact-match rates of 91.0% AWS, 99.0% Azure, and 94.9% GCP | 497/546, 98/99, and 94/99 scored records have Jaccard similarity 1.0 | Recomputed from raw JSON |
| Sample-based exact-match rates of 71.8% AWS, 93.0% Azure, and 92.0% GCP | 392/546, 93/100, and 92/100 scored records have Jaccard similarity 1.0 | Recomputed from raw JSON |
| Mutation outcomes: 302 more permissive, 48 less permissive, 44 incomparable, 126 equal, and 26 timeouts | `policysummarizer/results_mutation/mutation_results.json` | Recomputed exactly |
| Directional Jaccard statistics: 0.967 and 0.894 means, both with median 1.0 | Same mutation result file | Recomputed exactly |
| Approximate processing times of 5.8 s AWS, 2.4 s GCP, and 1.0 s Azure | Cloud result files contain solve and count times | Retained values support the reported order and approximate scale |
| PolicySummarizer sample-size sweep (100, 500, 1,000, 1,500, and 2,000 samples) | Paper figure, retained PolicySummarizer records, and `artifact_evaluation/run_sample_size_sweep.py` | Released protocol supports fresh traced runs with an available model |
| Z3+LLM baseline at 1,000 models | `Exp-4-Zelkova/z3_model_enum.py` | Released best-of-five runner supports fresh traced runs with an available model |

The paper text calls 91.0%, 99.0%, and 94.9% "mean similarity" in one place.
The retained records show that these values are the rates of exact Jaccard
matches. Arithmetic mean Jaccard values are separately reported by the audit
script. The camera-ready text should use "exact-match rate" for these values.

## LLM Comprehension Evaluation

`CPCA/cpca.py` contains the experimental workflow and prompts. The repository
also retains reconstructed policies, raw reconstruction responses, and the
consolidated `CPCA/experiment_results/experiment_0_results.json` file with 41
Claude 3.5 Sonnet records (38 completed and 3 recorded API errors).

## User Study

`policy_summarizer_user_study.zip` contains the study interface, consent flow,
questions, policies, and 41 unique participants' coded qualitative/task-answer
rows. This verifies the study size and preserves the participant-facing
materials and released response data.

## Badge Scope

The ISSRE 2026 artifact submission targets **Code and Dataset Reviewed**, which
includes the prerequisite **Available** badge. The API-free Docker reviewer
check demonstrates fundamental tool functionality, audits the released result
records, and verifies the consolidated data checksums.

The optional protocol runners make new experiments inspectable by preserving
inputs, generated samples/models, every candidate, repairs, verifier output,
model metadata, token usage, timing, failures, and coverage-aware summaries.
They support independent fresh runs while keeping stochastic provider output
separate from the deterministic artifact checks.
