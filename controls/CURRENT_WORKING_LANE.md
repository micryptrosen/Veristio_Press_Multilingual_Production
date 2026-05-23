# Current Working Lane

## Lane
A1 - Veristio Press Book 1 Spanish Native Review Execution or Hold v1

## Doctrine
Parallel Trailing Localization

## Current Tranche Scope
- Ground the Multilingual Production repo and prior Book 1 Draft V2/native-review assignment surfaces.
- Execute native-language review only if a real named native-language reviewer is documented.
- Record `HOLD_FOR_NATIVE_REVIEWER_ASSIGNMENT` when no named reviewer exists.
- Preserve reviewer coverage as `PROVISIONAL_INTERNAL_REVIEW_ALLOWED_FOR_DRAFT_ONLY`.
- Keep named human, native-language, technical, final sync/proof, metadata, ISBN, proof, and release gates pending.
- Preserve publication/release as blocked.
- Install verifier coverage and execute required gates.
- Commit and push to `origin/main` with parity checks.

## Stop Conditions
- Canonical Multilingual repo root or remote target is not the expected project.
- Starting HEAD diverges from expected and divergence is not understood.
- Draft V2 or native-review assignment packet is missing.
- Native-language review would require guessing or inventing a reviewer.
- Native-language review result would be implied without actual documented review.
- Hold artifacts would imply publication readiness or release readiness.
- Verifier failure.
- Unrelated dirty files appear.
