# Book 1 Spanish Reviewer Workflow V1

## Purpose

Define the reviewer workflow required before Book 1 Chapter 1 can move from `READY_WITH_CONDITIONS` toward Spanish translation draft packet preparation.

## Authority Boundary

Book 1 remains canonical for English manuscript text, English claims, citation posture, permissions posture, and readiness state. Multilingual Production owns Spanish terminology, reviewer workflow, translation QA gates, change sync, metadata/ISBN coordination status, and Spanish pilot controls.

## Reviewer Availability Status

`REVIEWERS_NOT_ASSIGNED`

No named Spanish terminology reviewer, native-language reviewer, technical reviewer, or final sync/proof reviewer is assigned in repo truth in this tranche.

## Reviewer Roles

| role | responsibility | required decision | availability_status | blocks |
|---|---|---|---|---|
| terminology reviewer | Approve, revise, or defer Book 1 EN-ES seed terms before draft work relies on them. | `TERMS_APPROVED`, `TERMS_APPROVED_WITH_NOTES`, or `TERMS_REJECTED_FOR_REVISION` | NOT_ASSIGNED | Draft packet terminology readiness. |
| native-language reviewer | Review Spanish readability, idiom, tone, and reader fit after a future draft exists. | `NATIVE_REVIEW_PASS`, `NATIVE_REVIEW_PASS_WITH_NOTES`, or `NATIVE_REVIEW_FAIL` | NOT_ASSIGNED | Native review gate and final release gates. |
| technical reviewer | Review conceptual accuracy and technical/workflow meaning against the locked English source and Book 1 authority. | `TECHNICAL_REVIEW_PASS`, `TECHNICAL_REVIEW_PASS_WITH_NOTES`, or `TECHNICAL_REVIEW_FAIL` | NOT_ASSIGNED | Technical review gate and final release gates. |
| final sync/proof reviewer | Confirm post-intake English changes, proof status, metadata/ISBN status, and release gate posture before any downstream release claim. | `FINAL_SYNC_PROOF_PASS`, `FINAL_SYNC_PROOF_PASS_WITH_NOTES`, or `FINAL_SYNC_PROOF_FAIL` | NOT_ASSIGNED | Final sync, proof, metadata/ISBN, and release gates. |

## Escalation Rules

- Escalate any ambiguity involving `authority`, `contribution`, `source truth`, `evidence`, `governance`, `verification`, `prompt`, `teammanship`, or title treatment through the Multilingual reviewer workflow.
- Escalate any English-source claim, citation, permissions, or readiness question back to Book 1 authority rather than changing English source text in this repo.
- Escalate metadata/ISBN/legal/distribution/release questions to the metadata/ISBN and release governance lane.
- If reviewer decisions conflict, hold the draft/release gate until the conflict is logged and resolved by the appropriate owner.

## What Can Proceed Without Named Reviewers

- Maintaining this glossary seed as `SEEDED_PENDING_REVIEW`.
- Maintaining packet, tracker, gap-log, and change-sync readiness records.
- Preparing reviewer assignment tasks and reviewer decision templates.
- Recording metadata/ISBN/proof/release as pending.

## What Cannot Proceed Without Reviewer Signoff

- Claiming Book 1 Spanish terminology readiness.
- Claiming native-language review completion.
- Claiming technical review completion.
- Claiming final sync/proof completion.
- Claiming Spanish release or publication readiness.

## Translation Boundary

This workflow setup does not begin Spanish translation, does not create a Spanish draft, and does not copy full Book 1 manuscript text into this repository.

## Next Corridor

`VERISTIO_PRESS_BOOK_1_SPANISH_REVIEWER_ASSIGNMENT_V1`
