# Book 1 Spanish Pilot Gap Log v1

## Gap Log Scope
This log records blockers and unknowns discovered during packet preparation for the Book 1 Spanish pilot. It does not resolve Book 1 manuscript authority, does not edit Book 1, and does not begin translation.

| gap_id | area | status | evidence | required closure |
|---|---|---|---|---|
| BOOK1-ES-GAP-001 | EN_TRANSLATION_READY | OPEN_BLOCKING | No `EN_TRANSLATION_READY` or translation-ready marker found in inspected Book 1 repo truth. | Book 1 repo must mark selected chapter(s) `EN_TRANSLATION_READY` or provide equivalent governed chapter lock accepted by this repo. |
| BOOK1-ES-GAP-002 | English lock version | OPEN_BLOCKING | Source HEAD observed, but no chapter-level English lock version found. | Record source branch, commit, chapter path, and explicit English lock version for selected chapter. |
| BOOK1-ES-GAP-003 | Spanish glossary | OPEN_BLOCKING | Multilingual EN-ES register contains governance seed terms only; no Book 1 Spanish terminology version exists. | Create or admit preliminary Book 1 EN-ES glossary terms before draft packet. |
| BOOK1-ES-GAP-004 | Claims/citations | OPEN_BLOCKING | Book 1 gap report says source-note/factual-support apparatus remains unresolved; AI labor source gap register has deferred/excluded items. | Book 1 must declare chapter-specific claims/citations status and unresolved issues for the selected chapter. |
| BOOK1-ES-GAP-005 | Figures/tables/captions | OPEN | No chapter-specific figures/tables/captions inventory found in inspected surfaces. | Confirm whether selected chapter has figures, tables, captions, or none. |
| BOOK1-ES-GAP-006 | Permissions/rights | OPEN_BLOCKING | Acknowledgments and permissions input surface keeps permission statuses pending. | Declare permissions/rights status for selected chapter and any paratext carried into translation packet. |
| BOOK1-ES-GAP-007 | Metadata/ISBN | OPEN_BLOCKING | Publication decision packet shows legal/entity/ISBN/publisher-of-record decisions pending and no ISBN assigned. | Record Spanish edition metadata/ISBN readiness as pending or close required legal/operator decisions before release gates. |
| BOOK1-ES-GAP-008 | Reviewer availability | OPEN_BLOCKING | No Spanish terminology, native-language, or technical reviewer assignments found in repo truth. | Assign or log owners for Spanish terminology, native-language, and technical review. |
| BOOK1-ES-GAP-009 | Change sync | READY_AS_EMPTY_LOG | No Spanish translation draft packet exists yet, so no post-intake English changes are tracked. | Use the Book 1 change-sync instance once a packet is admitted and English changes occur after intake. |
| BOOK1-ES-GAP-010 | Release readiness | BLOCKED_BY_DESIGN | Spanish output cannot be publication-ready until final sync, proof, metadata, ISBN, and release approval pass. | Preserve release block through all downstream translation and QA gates. |

## Current Intake Decision
HOLD_FOR_EN_TRANSLATION_READY

## Next Corridor
VERISTIO_PRESS_BOOK_1_EN_TRANSLATION_READY_GAP_CLOSURE_V1
