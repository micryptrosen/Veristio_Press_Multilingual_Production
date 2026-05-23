# Book 1 Spanish Change Sync Log v1

## Purpose
Prepare the Book 1 Spanish pilot change-sync surface before translation intake.

| change_id | date | book_id | chapter_number | english_lock_version_before | english_lock_version_after | english_state | translation_state_before | impact | required_action | owner | due_date | status |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| BOOK1-ES-SYNC-0000 | 2026-05-23 | BOOK-1-HCAS | 1 | N/A | BOOK1-CH01-EN-LOCK-V1 | EN_TRANSLATION_READY_WITH_CONDITIONS | READY_WITH_CONDITIONS | BASELINE_LOCK_ADMITTED_FOR_PACKET_REFRESH | Use locked source commit `bd0441d4a5cf8e5862a61421b3d515eb079afee4`; log any later Book 1 English changes before downstream release gates | Localization Lead TBD | TBD | Baseline Ready |
| BOOK1-ES-SYNC-0001 | 2026-05-23 | BOOK-1-HCAS | 1 | BOOK1-CH01-EN-LOCK-V1 | BOOK1-CH01-EN-LOCK-V1 | EN_TRANSLATION_READY_WITH_CONDITIONS | READY_WITH_CONDITIONS | DRAFT_PACKET_BASELINE_RECORDED | No English-source delta; keep future Book 1 changes in this log before review/release gates | Localization Lead TBD | TBD | No Sync Delta |

## Policy
- Use this log after packet refresh if Book 1 English changes occur after the `BOOK1-CH01-EN-LOCK-V1` baseline.
- Open critical sync items block release readiness.
- This log does not start Spanish translation and does not authorize Book 1 repo mutation.
