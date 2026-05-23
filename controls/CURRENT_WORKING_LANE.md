# Current Working Lane

## Lane
A1 - Veristio Press Book 1 Spanish Packet Refresh After EN Ready v1

## Doctrine
Parallel Trailing Localization

## Current Tranche Scope
- Ground the Multilingual Production repo and selected Book 1 packet surfaces.
- Inspect Book 1 readiness surfaces read-only for Chapter 1 `EN_TRANSLATION_READY_WITH_CONDITIONS`.
- Refresh Book 1 Spanish pilot packet surfaces without copying manuscript text.
- Move intake out of `HOLD_FOR_EN_TRANSLATION_READY` into `READY_WITH_CONDITIONS`.
- Update tracker, change-sync, gap log, receipt, and controls in this repo only.
- Preserve Spanish glossary/reviewer/metadata/ISBN/release conditions before any translation draft posture.
- Install verifier coverage and execute required gates.
- Commit and push to `origin/main` with parity checks.

## Stop Conditions
- Canonical Multilingual repo root or remote target is not the expected project.
- Starting HEAD diverges from expected and divergence is not understood.
- Book 1 repo cannot be uniquely identified.
- Book 1 has dirty/unrelated state that prevents reliable read-only evidence.
- Book 1 inspection would require mutation.
- Book 1 readiness decision is not `EN_TRANSLATION_READY` or `EN_TRANSLATION_READY_WITH_CONDITIONS`.
- Any artifact implies this repo owns canonical English manuscript text.
- Any artifact claims Spanish translation execution or publication readiness.
- Verifier failure.
- Unrelated dirty files appear.
