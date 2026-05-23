# Chapter Translation Tracker Template v1

## Fields
- book_id
- book_title
- source_language
- target_language
- chapter_number
- chapter_title
- english_state
- english_lock_version
- english_translation_ready_date
- translation_state
- translator_or_ai_source
- terminology_review_status
- native_review_status
- technical_review_status
- sync_status
- metadata_status
- isbn_status
- proof_status
- release_gate
- notes

## State Model
- EN_DRAFTING
- EN_REVIEW
- EN_TRANSLATION_READY
- ES_TRANSLATION_DRAFT
- ES_TERMINOLOGY_REVIEW
- ES_NATIVE_REVIEW
- ES_TECHNICAL_REVIEW
- ES_SYNC_PENDING
- ES_PUBLICATION_READY

## Sample Row
| book_id | book_title | source_language | target_language | chapter_number | chapter_title | english_state | english_lock_version | english_translation_ready_date | translation_state | translator_or_ai_source | terminology_review_status | native_review_status | technical_review_status | sync_status | metadata_status | isbn_status | proof_status | release_gate | notes |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| SAMPLE-BOOK | Sample Book | en | es | 1 | Sample Chapter | EN_TRANSLATION_READY | v1.0-lock | 2026-05-23 | ES_TRANSLATION_DRAFT | TBD | Pending | Pending | Pending | Not Required | Pending | Pending | Pending | Hold | Template row |