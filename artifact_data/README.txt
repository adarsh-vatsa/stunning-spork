ISSRE 2026 ARTIFACT DATA SNAPSHOT
================================

This directory consolidates the data retained for the paper
"Neurosymbolic Characterization for Reliable Access Control Policy Analysis."
It is a convenience copy for artifact reviewers. The executable scripts remain
in their original repository directories.

Contents
--------

- Dataset/: 41 original AWS policies used by the Quacky-based experiments.
- policysummarizer/: cloud-provider inputs, generated assignments/bindings,
  retained direct/sample simplification results, mutation results, figures,
  and the analysis notebook.
- CPCA/experiment_results/: retained policy-comprehension model responses,
  reconstructed policies, checkpoints, and consolidated partial results.
- legacy/: CSV, JSON, JSONL, log, progress, and text outputs retained from the
  supporting experiment and fine-tuning directories.
- regex/: retained historical regex output.
- policy_summarizer_user_study.zip: participant-facing study materials and
  the public coded response data retained in the artifact.
- MANIFEST.sha256: SHA-256 checksums for the files in this directory.

The retained historical data does not make stochastic LLM responses exactly
reproducible. New LLM-backed runs require compatible provider API keys, paid
credit and quota, network access, and access to the requested model versions.
The API-free reviewer workflow audits this data without making model calls.
