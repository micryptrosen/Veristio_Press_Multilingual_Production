# Current Working Lane

## Lane
A1 - Veristio Press Book 1 Spanish Draft Review and Terminology Pass v1

## Doctrine
Parallel Trailing Localization

## Current Tranche Scope
- Ground the Multilingual Production repo and Book 1 Spanish draft/reviewer/glossary surfaces.
- Review the provisional Chapter 1 Spanish draft under internal draft-only coverage.
- Record first-pass terminology findings, revision needs, and review status decision.
- Preserve reviewer coverage as `PROVISIONAL_INTERNAL_REVIEW_ALLOWED_FOR_DRAFT_ONLY`.
- Keep named human, native-language, technical, final sync/proof, metadata, ISBN, proof, and release gates pending.
- Preserve publication/release as blocked.
- Install verifier coverage and execute required gates.
- Commit and push to `origin/main` with parity checks.

## Stop Conditions
- Canonical Multilingual repo root or remote target is not the expected project.
- Starting HEAD diverges from expected and divergence is not understood.
- Spanish draft packet is missing.
- Draft status is not provisional/draft-only.
- Review would require claiming named human, native-language, technical, or final review completion without documented reviewers.
- Review artifacts would imply publication readiness or release readiness.
- Verifier failure.
- Unrelated dirty files appear.
