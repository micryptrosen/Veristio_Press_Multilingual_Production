# Arrival Anchor (Current)

## Anchor
A1 - Restore Real DeepSeek API Advisory Integration V1

## Canonical Repository
D:\Dev\CGPT\Projects\Veristio\Veristio_Press_Multilingual_Production

## Source Doctrine
Parallel Trailing Localization with English canonical source authority in Book repos and process/governance authority in this Multilingual Production repo.

Book 1 remains the canonical English owner for manuscript text, readiness, claims, citations, and permissions.

## DeepSeek API Integration Posture
- Runner: `tools/deepseek_advisory_review.py`.
- Connectivity verifier: `tools/verify_deepseek_api_connectivity.ps1`.
- Integration document: `docs/integration/DEEPSEEK_API_ADVISORY_INTEGRATION_V1.md`.
- Restore receipt: `docs/governance/receipts/DEEPSEEK_API_ADVISORY_INTEGRATION_RESTORE_RECEIPT_V1.md`.
- `DEEPSEEK_API_KEY` detected: yes, without printing.
- API base URL: `https://api.deepseek.com`.
- Endpoint: `/chat/completions`.
- Preferred model: `deepseek-v4-flash`.
- Fallback model: `deepseek-v4-pro`.
- Live API connectivity: PASS.
- Observed successful models during live verifier runs: `deepseek-v4-flash`; `deepseek-v4-pro` via fallback after one preferred-model empty-content response..
- Test output path: `C:\Users\Veristio Writer\AppData\Local\Temp\veristio_deepseek_api_connectivity\deepseek_connectivity_output.md`.

## Current Packet Posture
- Selected candidate: `CANDIDATE-001` - Human Creativity + AI Synthesis.
- Source repo path: `D:\Dev\CGPT\Projects\Veristio\Book 1 Human Creativity + AI`.
- Locked source commit: `bd0441d4a5cf8e5862a61421b3d515eb079afee4`.
- Selected chapter: Chapter 1 - Work Changed Before Most People Noticed.
- English lock version: `BOOK1-CH01-EN-LOCK-V1`.
- English state: `EN_TRANSLATION_READY_WITH_CONDITIONS`.
- Current Spanish draft: `BOOK_1_CHAPTER_1_SPANISH_DRAFT_V3.md`.
- Prior non-API-backed DeepSeek advisory artifact: retained as historical advisory record with provenance warning; next corridor should rerun with the real DeepSeek API.
- Human review: pending.
- Native-language review: pending.
- Technical review: pending.
- Final sync/proof review: pending.
- Metadata/ISBN/release gates: pending.
- Publication/release boundary: blocked.
- Next corridor: `RERUN_BOOK_1_CHAPTER_1_SPANISH_DRAFT_V3_REAL_DEEPSEEK_ADVISORY_REVIEW_V1`.

## Continuation Instruction
Resume from `controls/CURRENT_WORKING_LANE.md`, run `tools\verify_deepseek_api_connectivity.ps1`, and use only `tools\deepseek_advisory_review.py` or another real DeepSeek API-backed mechanism for future DeepSeek advisory output. Do not fake DeepSeek output, do not call internal model output DeepSeek, and do not treat DeepSeek advisory output as human/native/final review. Keep publication and release blocked until all required gates pass.
