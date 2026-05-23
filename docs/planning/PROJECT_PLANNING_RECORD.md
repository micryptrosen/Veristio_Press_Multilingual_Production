# Project Planning Record

## Planning Snapshot
- Date: 2026-05-23
- Phase: A1 Project Birth, Integration Contracting, Pilot Selection, Packet Preparation, Packet Refresh, Glossary/Reviewer Setup, Reviewer Assignment, Draft Packet, First Internal Review, Draft V2 Prep, Native Review Assignment Prep, Native Review Hold, Native Reviewer Gap Repair, and Draft V3 Claude Advisory Corrections
- Primary Objective: Apply Claude advisory orthographic/accent and safe phrasing corrections to Book 1 Chapter 1 Spanish Draft V2 to create Draft V3 without pretending human/native/final review has occurred.

## Planned Deliverables
- Book 1 Chapter 1 Spanish Draft V3.
- Claude advisory correction pass record.
- Draft V3 change log.
- Book 1 Spanish Draft V3 Claude advisory corrections receipt.
- Draft V3 verifier and gate execution.
- Updated review queue, revision queue, tracker, gap log, native-review status decision, controls, and handoff.

## Current Packet Posture
- Selected candidate: `CANDIDATE-001` - Human Creativity + AI Synthesis.
- Selected chapter: Chapter 1 - Work Changed Before Most People Noticed.
- English state: `EN_TRANSLATION_READY_WITH_CONDITIONS`.
- English lock version: `BOOK1-CH01-EN-LOCK-V1`.
- Locked source commit: `bd0441d4a5cf8e5862a61421b3d515eb079afee4`.
- Reviewer coverage decision: `PROVISIONAL_INTERNAL_REVIEW_ALLOWED_FOR_DRAFT_ONLY`.
- Draft status: `ES_TRANSLATION_DRAFT_V3_ADVISORY_CORRECTED_NATIVE_REVIEW_HELD_FOR_OPERATOR_SELECTION`.
- Claude advisory correction status: `CLAUDE_ADVISORY_CORRECTIONS_APPLIED_TO_DRAFT_V3`.
- Review status decision: `PROVISIONAL_REVIEW_PASS_WITH_REVISIONS_REQUIRED`.
- Post-revision status decision: `READY_FOR_NATIVE_LANGUAGE_REVIEW_WITH_CONDITIONS`.
- Terminology status: `CLAUDE_ADVISORY_CORRECTIONS_APPLIED_NAMED_REVIEW_PENDING`.
- Revision queue: advisory corrections applied, named/native review pending.
- Native-review prep: ready with conditions.
- Native-review assignment status: `NATIVE_REVIEW_PACKET_READY_REVIEWER_PENDING`.
- Native-review execution/hold decision: `HOLD_FOR_NATIVE_REVIEWER_ASSIGNMENT`.
- Native-review gap repair status: `HOLD_FOR_OPERATOR_REVIEWER_SELECTION`.
- Human review: pending.
- Native-language review: pending.
- Technical review: pending.
- Final sync/proof review: pending.
- Metadata/ISBN/release gates: pending.
- Publication/release boundary: blocked.
- Required next corridor: `VERISTIO_PRESS_BOOK_1_SPANISH_REVIEWER_SELECTION_OR_NATIVE_REVIEW_EXECUTION_V1`.

## Risk Controls
- Stop on path or remote mismatch.
- Treat known HEAD mismatch as understood only because later reviewer-copy and correction-revert commits are already present.
- Stop if Draft V2 is missing.
- Stop if advisory correction input would require claiming named human/native/final review.
- Stop if any artifact implies canonical English authority transfer.
- Stop if any artifact claims human/native/final review completion.
- Stop if any artifact claims Spanish publication readiness.
- Stop on verifier failures.
- Leave pre-existing untracked advisory input unstaged unless operator requests archival.
