# Book Repo Translation Packet Template v1

Use this packet to admit a chapter from a source Book repo into the Multilingual Production workflow. Packet admission is scope authorization only and does not transfer canonical manuscript authority.

## Template
- packet_id:
- source_book_id:
- source_book_title:
- source_repo_path:
- source_branch:
- source_commit:
- source_chapter_path:
- chapter_number:
- chapter_title:
- source_language:
- target_language:
- english_state:
- english_lock_version:
- translation_ready_date:
- glossary_version:
- claims_status:
- citation_status:
- figures_tables_status:
- permissions_rights_status:
- intended_output_format:
- receiving_translation_tracker:
- authority_boundary:
- notes:

## Required Packet Rules
- `english_state` must equal `EN_TRANSLATION_READY` at intake.
- `english_lock_version` must match the source repo lock declaration for the admitted chapter.
- `source_commit` must be immutable and traceable in the source Book repo.
- `authority_boundary` must state that the source Book repo remains canonical for English manuscript authority.
- Any post-intake English changes must be recorded through translation change sync before release.
