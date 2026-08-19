# Large Language Model Synthesized Access Control Policy Verification

## ISSRE 2026 Artifact Evaluation

The reviewer instructions for the **Code and Dataset Reviewed** artifact,
including the prerequisite **Available** badge, are in
[`README.txt`](README.txt). Start the interactive reviewer console with:

```bash
bash artifact_evaluation/artifact.sh
```

Choose option 1 for the complete API-free reviewer check, or run it directly:

```bash
bash artifact_evaluation/artifact.sh review
```

The optional live interface is available at
[policysummarizer.xyz](https://policysummarizer.xyz/). Artifact evaluation does
not depend on the hosted service.

## Overview

This repository contains the code and experimental artifacts for verifying LLM-synthesized access control policies. Our research explores techniques for generating, analyzing, and verifying access control policies using large language models, with a focus on AWS IAM policies, Azure role definitions, and GCP IAM bindings using formal verification methods.

## Research Approach

Our methodology combines:
- **Natural Language Processing**: Converting policy descriptions to formal specifications
- **Formal Verification**: Using SMT solvers and model counting for policy analysis
- **Quantitative Analysis**: Measuring policy permissiveness and semantic equivalence
- **Pattern Synthesis**: Generating regex patterns from example strings
- **Policy Summarization**: Producing human-readable summaries of complex AWS, Azure, and GCP policies via regex simplification and resource path verification

We evaluate state-of-the-art language models on their ability to:
1. Generate syntactically and semantically correct policies
2. Comprehend and explain existing policies
3. Synthesize patterns that capture policy resource constraints
4. Maintain semantic equivalence across transformations
5. Summarize complex policy behaviors into concise, verifiable descriptions

## Repository Structure

```
├── artifacts/              # Quacky tool + interactive web demo with Docker deployment
│   ├── Dockerfile         # Multi-stage Docker build (ABC solver + FastAPI app)
│   ├── deploy.sh          # Deployment helper script
│   ├── src/               # Quacky source code (with modifications)
│   ├── web/               # FastAPI web interface
│   │   └── app.py         # SSE-based policy analysis web app
│   ├── samples/           # Sample AWS IAM policies
│   ├── iam-dataset/       # IAM dataset for experiments
│   └── tutorial.md        # Step-by-step usage tutorial
│
├── policysummarizer/       # Policy Summarization Experiments (NEW)
│   ├── regex_summarizer.py # Core regex-based policy summarizer (AWS/Azure/GCP)
│   ├── mutation_comparator.py # Policy mutation comparison
│   ├── assignment_generator.py # GCP IAM assignment generation
│   ├── binding_generator.py    # GCP IAM binding generation
│   ├── flatten_role.py    # Azure role definition flattening
│   ├── assignments/       # Generated GCP IAM assignments
│   ├── bindings/          # Generated GCP IAM bindings
│   ├── results/           # Summarization results
│   └── results_report.ipynb # Analysis and figures
│
├── CPCA/                   # Core Policy Comprehension Assessment framework
│   └── cpca.py            # Main experiment runner
│
├── Exp-1/                  # Policy Generation and Comparison
│   └── Exp-1.py           # Dual policy analysis
│
├── Exp-2/                  # Resource Summarization
│   ├── Exp-2.py           # Regex synthesis from policies
│   └── tests/             # Test cases
│
├── Exp-3/                  # Factors Affecting Summarization
│   └── Exp-3.py           # Multi-string analysis
│
├── Exp-4-Zelkova/         # Z3 + LLM baseline
│   └── z3_model_enum.py   # Reproducible model enumeration, regex generation, and scoring
│
├── Dataset/               # AWS IAM Policy Dataset
├── Fine-tuning/           # Model Fine-tuning Experiments
├── Simplification-Exp/    # Policy Simplification Studies
└── regex/                 # Regex Generation Results
```

## Quick Start with Docker (Recommended)

The `artifacts/` directory contains a fully dockerized deployment of the Quacky tool and web interface:

```bash
cd artifacts/
docker build -t quacky .
docker run -e ANTHROPIC_API_KEY=your_key -p 8000:8000 quacky
# Access at http://localhost:8000
```

The Docker image builds the ABC solver from source and bundles all dependencies. Build time is approximately 5–10 minutes on first run.

## Prerequisites for Local Setup

- Python 3.8+
- API keys for LLM services (at least one required)
- ABC (Automata-Based model Counter)
- Quacky (included in `artifacts/` with modifications)

## Installation

1. Clone this repository

2. Install Python dependencies:
   ```bash
   pip install -r requirements.txt
   ```

3. Set up API keys:
   Create `.env` file with your keys:
   ```
   ANTHROPIC_API_KEY=your_key
   OPENAI_API_KEY=your_key
   GOOGLE_API_KEY=your_key
   ```

4. Install the external ABC solver using its
   [official installation guide](https://github.com/vlab-cs-ucsb/ABC/blob/master/INSTALL.md),
   then verify the installation with `abc --help`.

5. Quacky is included in the `artifacts/` directory with necessary modifications.

## Experiments

### Experiment 1: Policy Generation and Comparison
Evaluates LLM capabilities in generating and comparing access control policies.
```bash
cd Exp-1/
python Exp-1.py
```

### Experiment 2: Resource Summarization
Tests the ability to generate concise regex patterns that summarize policy resources.
```bash
cd Exp-2/
python Exp-2.py
```

### Experiment 3: Factors Affecting Summarization Accuracy
Investigates how various factors (string count, complexity) affect pattern synthesis accuracy.
```bash
cd Exp-3/
python Exp-3.py
```

### Experiment 4: Z3 + LLM Baseline

This experiment encodes each of the 41 original AWS policies with Quacky,
enumerates up to 1,000 satisfying resource strings with Z3, asks Claude 4
Sonnet for five regex candidates, repairs syntactically invalid candidates
once, and retains the candidate with the highest Jaccard similarity. Every
model file, candidate, diagnostic, selected regex, and policy-level result is
saved. Aggregate statistics include perfect matches and report unscored
policies separately.

Install both the repository and Quacky dependencies, then set an Anthropic API
key:

ABC is maintained as a separate research project and is not vendored here.
Install it using the official
[ABC installation guide](https://github.com/vlab-cs-ucsb/ABC/blob/master/INSTALL.md),
then confirm that `abc --help` succeeds. The runner checks for this executable
before making any API calls.

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt -r artifacts/requirements.txt
export ANTHROPIC_API_KEY="your-key"

python Exp-4-Zelkova/z3_model_enum.py \
  --max-models 1000 \
  --num-candidates 5 \
  --syntax-repairs 1 \
  --output-dir Exp-4-Zelkova/results-1000
```

Use `--resume` to continue an interrupted run. To verify SMT generation and Z3
enumeration without making LLM calls, add `--enumerate-only`; use a fresh output
directory for that check. The final `summary.json` reports the ordinary mean
over every policy with a usable Jaccard score. It never removes perfect
matches from the average.

### Five-Size PolicySummarizer Protocol

The paper's sample-size study uses 100, 500, 1,000, 1,500, and 2,000 strings
over the 41 original policies. The Docker-backed runner preserves the sample
sets, all five LLM candidates, syntax repairs, model metadata, token usage,
timing, and coverage-aware aggregate statistics:

The full run requires an Anthropic API account, an API key, sufficient paid
credit and rate-limit quota, network access, and access to the selected model.
It is not required for the API-free Reviewed-badge smoke test.

```bash
export ANTHROPIC_API_KEY="your-key"
bash artifact_evaluation/run_protocol_replication.sh \
  --model "your-available-model-id" --resume
```

This paid sweep makes 1,025 initial LLM calls plus any syntax repairs and can
take many hours. A one-policy, API-free pipeline check is available with:

```bash
bash artifact_evaluation/run_protocol_replication.sh \
  --enumerate-only --sample-sizes 100 --start-from 0 --end-at 0
```

The paper used a Claude 4 Sonnet snapshot. LLM responses are stochastic, and a
different or no-longer-identical model snapshot cannot reproduce historical
responses bit for bit. Such a run validates the experimental protocol and
produces a new replication result; it should not be described as an exact
reconstruction of the accepted paper's raw outputs.

### CPCA: Comprehensive Policy Analysis
Full experimental framework for policy comprehension assessment.
```bash
cd CPCA/
python cpca.py --models <model_name> --policy-dir <path> --output-dir results
```

### Policy Summarizer (New)
Regex-based policy summarization with LLM-aided simplification and resource path verification. Supports AWS IAM policies, Azure role definitions/assignments, and GCP IAM role bindings.
```bash
cd policysummarizer/
python regex_summarizer.py
```

## Key Features

- **Policy Generation**: Natural language to AWS IAM policy conversion
- **Quantitative Comparison**: SMT-based policy space analysis
- **Pattern Synthesis**: Regex generation from example strings
- **Formal Verification**: Using ABC and Z3 solvers
- **Policy Summarization**: Automated regex simplification and resource verification
- **Interactive Demo**: Web-based interface with streaming results
- **Multi-Cloud Support**: AWS IAM, Azure RBAC, and GCP IAM policy analysis

## Technical Components

- **Quacky**: Translates policies to SMT-LIB format for model counting
- **ABC Solver**: Performs efficient model counting for policy analysis
- **Z3 Theorem Prover**: Used for formal verification in Exp-4
- **FastAPI Interface**: Web-based demo with SSE streaming in `artifacts/web/`

## Data

The `Dataset/` folder contains AWS IAM policies used in experiments. The `policysummarizer/` directory contains GCP IAM assignments/bindings and supports Azure role definitions. To use your own:
1. Place policies in JSON format in the appropriate folder
2. Update experiment scripts to point to your data
3. Results will be saved in CSV format in respective experiment folders

## Replication Notes

Due to the non-deterministic nature of language models, exact result replication may vary. However, the techniques and trends should be consistent. The Quacky tool in `artifacts/` includes necessary modifications for our experiments.

## Prompts

All LLM prompts used across experiments are documented below for reproducibility.

### Experiment 1: Policy Explanation

**Prompt (Policy → Natural Language Description):**
```
Please provide a clear, comprehensive natural language explanation of what this AWS IAM
policy allows or denies in a manner that allows the reconstruction of this policy.
Don't respond with your thought process at all. Make sure you only respond with the
relevant explanation and nothing else. And make sure that the explanation is still in
natural language otherwise it kinda defeats the purpose.

Policy:
{policy_content}
```

**Prompt (Description → Policy Reconstruction):**
```
Based on this explanation, generate a complete AWS IAM policy in JSON format.
Only output valid JSON, no other text.

Explanation:
{description}
```

**Prompt (Z3 Models → Regex) — System:**
```
When asked to give a regex, provide ONLY the regex pattern itself. Do not include any
explanations, markdown formatting, or additional text. The response should be just the
regex pattern, nothing else. This is a highly critical application and it is imperative
to get this right. Just give me the regex.
```

**Prompt (Z3 Models → Regex) — User:**
```
Give me a single regex that characterizes the pattern in the following set of Z3 model
strings. The regex should capture the essential structure and be reasonably general but
not overly permissive:

{model_strings}

Response:
```

### Experiment 2: Regex Synthesis from Strings

**Developer Prompt:**
```
Output only the regex pattern (no quotes, no prose).

Constraints (safe for DFA/ABC-style tooling):
- Do NOT use ^ or $, \A \Z \z \G.
- Do NOT use any (?...) constructs at all:
  non-capturing (?: ), lookarounds (?=, ?!, ?<=, ?<!), inline flags (?i),
  atomic (?>), conditionals, named groups, or backreferences \1..\9.
- Do NOT use lazy quantifiers (*?, +?, ??, {m,n}?).
- Match substrings; do not add boundaries.
- Do NOT invent rules about '/', spaces, or extensions unless forced by examples.
- Keep it specific; prefer bounded {m,n} and tight positive classes.
```

**User Prompt:**
```
Give a single regex that matches ALL of these strings (substring semantics).
Return ONLY the regex pattern, nothing else:

{strings}
```

### Experiment 4: Regex from Z3 Models (with Extended Thinking)

**System Prompt:**
```
When asked to give a regex, provide ONLY the regex pattern itself. Do not include any
explanations, markdown formatting, or additional text. The response should be just the
regex pattern, nothing else. This is a highly critical application and it is imperative
to get this right. Just give me the regex.
```

**User Prompt:**
```
Give me a single regex that accepts each string in the following set of strings.
Make sure that you carefully go through each string before forming the regex.
It should be close to optimal and not super permissive:

{strings}

Response:
```

### CPCA: Policy Comprehension Assessment

**Prompt (Explanation Generation) — Used in Steps 1 and 4:**
```
Please provide a clear, comprehensive natural language explanation of what this AWS IAM
policy allows or denies in a manner that allows the reconstruction of this policy.
Don't respond with your thought process at all. Make sure you only respond with the
relevant explanation and nothing else. And make sure that the explanation is still in
natural language otherwise it kinda defeats the purpose.

Policy:
{policy_json}
```

**Prompt (Request Outcome Prediction) — Step 2:**
```
Given this AWS IAM policy:
{policy_json}

For each of the following requests, predict whether the policy would Allow or Deny access.
Respond with exactly one word per line: either "Allow" or "Deny".

Requests:
1. Principal: {principal}, Action: {action}, Resource: {resource}
...
```

**Prompt (Policy Reconstruction) — Step 3:**
```
Based on this explanation, generate a complete AWS IAM policy in JSON format.
Only output valid JSON, no other text.

Explanation:
{original_explanation}
```

### Policy Summarizer: Regex Simplification

**Prompt (DFA Regex → Simplified Regex) — Initial:**
```
You are an expert in regular expressions and cloud security policies.

Given the following regex extracted from a DFA representing cloud resource access patterns:

{regex}

Please generate a SIMPLIFIED, human-readable equivalent regex that matches the same
resources.

Make it shorter and more readable while preserving the exact semantic meaning.

IMPORTANT: Respond with ONLY the simplified regex on a single line. No explanation, no
markdown, no backticks, no anchors (^ or $).
Give the output as a raw regex. Do not assume this regex will be used in Python or any
standard regex engine. Output a plain, raw regex pattern as would be used with grep or sed.
```

**Prompt (DFA Regex → Simplified Regex) — Retry with Feedback:**
```
You are an expert in regular expressions and cloud security policies.

You previously generated a simplified regex, but it did NOT match the same resources as
the original.

ORIGINAL DFA REGEX:
{regex}

YOUR PREVIOUS ATTEMPT:
{previous_regex}

COMPARISON RESULTS:
- Original regex matched: {baseline_count} resources
- Your regex matched: {synthesized_count} resources
- Jaccard Similarity: {jaccard_similarity} (should be close to 1.0)

ANALYSIS:
- If your regex matched FEWER resources, you were TOO RESTRICTIVE. Make it more permissive.
- If your regex matched MORE resources, you were TOO PERMISSIVE. Make it more restrictive.

Please generate a NEW simplified regex that is semantically equivalent to the original.

IMPORTANT: Respond with ONLY the corrected regex on a single line. No explanation, no
markdown, no backticks, no anchors (^ or $).
Give the output as a raw regex. Do not assume this regex will be used in Python or any
standard regex engine. Output a plain, raw regex pattern as would be used with grep or sed.
```

**Prompt (Samples → Regex) — Initial:**
```
You are an expert in regular expressions and cloud security policies.

I will provide you with sample strings representing cloud resource paths. Generate a regex
that matches these strings and similar ones.

SAMPLE STRINGS:
{samples}

Analyze the samples and generate a regex pattern that matches all of them. Look for common
patterns and variable parts.

IMPORTANT: Respond with ONLY the regex on a single line. No explanation, no markdown, no
backticks, no anchors (^ or $).
Give the output as a raw regex. Do not assume this regex will be used in Python or any
standard regex engine. Output a plain, raw regex pattern as would be used with grep or sed.
```

**Prompt (Samples → Regex) — Retry with Feedback:**
```
You are an expert in regular expressions and cloud security policies.

You previously generated a regex from sample strings, but it did NOT match the same
resources as the original.

SAMPLE STRINGS:
{samples}

YOUR PREVIOUS ATTEMPT:
{previous_regex}

COMPARISON RESULTS:
- Original regex matched: {baseline_count} resources
- Your regex matched: {synthesized_count} resources
- Jaccard Similarity: {jaccard_similarity} (should be close to 1.0)

ANALYSIS:
- If your regex matched FEWER resources, you were TOO RESTRICTIVE. Make it more permissive.
- If your regex matched MORE resources, you were TOO PERMISSIVE. Make it more restrictive.

Please generate a NEW regex that matches the same resources as the original.

IMPORTANT: Respond with ONLY the corrected regex on a single line. No explanation, no
markdown, no backticks, no anchors (^ or $).
Give the output as a raw regex. Do not assume this regex will be used in Python or any
standard regex engine. Output a plain, raw regex pattern as would be used with grep or sed.
```

## Citation

If you use this code or our findings in your research, please cite:
```
[Citation information will be added upon publication]
```

## License

MIT License

## Contact

For questions about the experiments or techniques, please open an issue on GitHub.
