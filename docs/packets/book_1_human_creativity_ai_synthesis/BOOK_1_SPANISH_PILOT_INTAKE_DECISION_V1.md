# Book 1 Spanish Pilot Intake Decision v1

## Decision
READY_WITH_CONDITIONS

## Allowed Decision Set
- READY_FOR_TRANSLATION_DRAFT_PACKET
- READY_WITH_CONDITIONS
- HOLD_FOR_EN_TRANSLATION_READY
- HOLD_FOR_SOURCE_OR_CLAIM_GAPS
- HOLD_FOR_GLOSSARY_REVIEW
- HOLD_FOR_REVIEWER_AVAILABILITY
- HOLD_FOR_METADATA_ISBN_READINESS

## Decision Basis
Book 1 is the selected Spanish pilot candidate and Chapter 1 is the preferred candidate chapter. Book 1 now records Chapter 1 as `EN_TRANSLATION_READY_WITH_CONDITIONS`, with English lock version `BOOK1-CH01-EN-LOCK-V1` and locked source commit `bd0441d4a5cf8e5862a61421b3d515eb079afee4`. The Multilingual packet can leave the English-readiness hold, but Spanish-side glossary, reviewer, metadata/ISBN, permissions/publication, source-note, and release gates remain open.

## Closed Conditions
- Book 1 marked Chapter 1 `EN_TRANSLATION_READY_WITH_CONDITIONS` on 2026-05-23.
- English lock version `BOOK1-CH01-EN-LOCK-V1` is recorded.
- Locked English source commit `bd0441d4a5cf8e5862a61421b3d515eb079afee4` is recorded.
- Book 1 governance HEAD after readiness closure is `db3e5b92784ab6e01c4882b283aaa78d22399a44`.

## Remaining Conditions Before Translation Draft
- Preliminary Book 1 Spanish glossary/termbase seed exists and must be approved, revised, or deferred by the terminology reviewer.
- Spanish terminology, native-language, and technical reviewer availability must be recorded.
- Final sync/proof reviewer availability must be recorded.
- Metadata/ISBN/legal/distribution status must remain visible as pending/not ready until separate release gates close.
- Final permissions/publication readiness remains blocked until downstream release controls pass.
- Final book-wide source-note apparatus remains governed by Book 1 unless separately admitted through Multilingual sync/governance.

## Glossary And Reviewer Setup Result
- Terminology seed: `SEEDED_PENDING_REVIEW`
- Reviewer workflow: `CREATED`
- Named reviewer assignment: `NO_NAMED_REVIEWERS_ASSIGNED`
- Reviewer coverage decision: `PROVISIONAL_INTERNAL_REVIEW_ALLOWED_FOR_DRAFT_ONLY`
- Draft readiness gate: `READY_WITH_CONDITIONS`
- Publication/release boundary: blocked pending human/native/final review, final sync, proof, metadata, ISBN, and release gates.

## Authority Boundary
Book 1 remains the canonical English manuscript authority. This Multilingual Production repo owns packet governance, gap logging, tracker readiness, change-sync readiness, metadata/ISBN coordination status, and Spanish pilot workflow controls only. No Book 1 repo mutation is authorized by this decision.

## Translation Status
`PROVISIONAL_DRAFT_ONLY_REVIEW_PENDING`

A target-language draft artifact is recorded for review routing only. It is not human reviewed, not native reviewed, not final, and not publication ready.

## Next Corridor
VERISTIO_PRESS_BOOK_1_SPANISH_DRAFT_REVIEW_AND_TERMINOLOGY_PASS_V1
