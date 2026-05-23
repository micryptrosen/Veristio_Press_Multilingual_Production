# Current Working Lane

## Lane
A1 - Apply Claude Advisory Corrections to Book 1 Spanish Draft V3

## Doctrine
Parallel Trailing Localization

## Current Tranche Scope
- Ground the Multilingual Production repo and prior Book 1 Spanish Draft V2/native-review hold surfaces.
- Use Claude advisory feedback supplied by the controller/user as advisory correction input only.
- Create Book 1 Chapter 1 Spanish Draft V3 with safe orthographic/accent and phrasing corrections.
- Record terminology decisions for IA, workflow/checklist/draft/deliverables/dashboard terms, `contribuidor`, and `fuente única de verdad`.
- Preserve native review execution/hold decision as `HOLD_FOR_NATIVE_REVIEWER_ASSIGNMENT` until a real named reviewer is documented.
- Keep named human, native-language, technical, final sync/proof, metadata, ISBN, proof, and release gates pending.
- Preserve publication/release as blocked.
- Install verifier coverage and execute required gates.
- Commit and push to `origin/main` with parity checks.

## Stop Conditions
- Canonical Multilingual repo root or remote target is not the expected project.
- Starting HEAD diverges from expected and divergence is not understood.
- Draft V2 is missing.
- Claude advisory corrections would require claiming named human/native review completion.
- Corrections would imply final review, publication readiness, release approval, or upload readiness.
- Verifier failure.
- Unrelated dirty files appear.

## Known Start Note
The requested `Current known HEAD` was `70b2fda5ab7835a1bf6103a3a099a16ca484d5ce`. Actual start for this tranche was later because the reviewer-copy export commit and the revert of the mistaken contract-alignment correction were already present and understood. The working tree also contained pre-existing untracked advisory input under `inputs/`; it was used as input and not staged by this tranche.
