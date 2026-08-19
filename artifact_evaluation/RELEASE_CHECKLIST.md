# ISSRE Artifact Release Checklist

The target is **Available + Reviewed**. Complete these steps only after the
artifact contents and paper metadata are final.

1. Run `bash artifact_evaluation/smoke_test.sh` from a clean checkout.
2. Run `python3 artifact_evaluation/verify_retained_results.py`.
3. Reserve a Zenodo DOI for the GitHub release.
4. Add that DOI to `README.txt`, `CITATION.cff`, and the camera-ready paper.
5. Commit the final artifact tree and create a version tag.
6. Run `bash artifact_evaluation/build_release_archive.sh 1.0.0`.
7. Upload the generated ZIP to the reserved Zenodo record and publish it.
8. Verify the Zenodo landing page, license, authors, checksum, and DOI.
9. Upload the accepted paper with the required artifact cover page.

The hosted deployment is optional evidence of availability. Reviewers must be
able to complete the local Docker smoke test without the website or an API key.

Official instructions:
https://cyprusconferences.org/issre2026/cfp-artifacts/
