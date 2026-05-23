# Current Working Lane

## Lane
A1 - Veristio Press Book 1 Spanish Translation Draft Packet v1

## Doctrine
Parallel Trailing Localization

## Current Tranche Scope
- Ground the Multilingual Production repo and Book 1 Spanish packet/readiness/reviewer/glossary surfaces.
- Read the locked Book 1 Chapter 1 source at `bd0441d4a5cf8e5862a61421b3d515eb079afee4` without editing Book 1.
- Create a controlled provisional Spanish draft packet and review-routing artifacts.
- Store Spanish target draft text and metadata, not duplicated full English source text.
- Preserve reviewer coverage as `PROVISIONAL_INTERNAL_REVIEW_ALLOWED_FOR_DRAFT_ONLY`.
- Preserve terminology, native-language, technical, final sync/proof, metadata, ISBN, proof, and release gates as pending.
- Preserve publication/release as blocked.
- Install verifier coverage and execute required gates.
- Commit and push to `origin/main` with parity checks.

## Stop Conditions
- Canonical Multilingual repo root or remote target is not the expected project.
- Starting HEAD diverges from expected and divergence is not understood.
- Book 1 locked source commit cannot be read.
- Reviewer assignment state is not draft-allowed.
- Draft packet would imply publication readiness or release readiness.
- Verifier failure.
- Unrelated dirty files appear.
