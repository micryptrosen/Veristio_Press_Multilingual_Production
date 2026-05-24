# Project Planning Record

## Planning Snapshot
- Date: 2026-05-23
- Phase: A1 Project Birth through Draft V3 Advisory Controls and Real DeepSeek API Integration Restore
- Primary Objective: Restore a real DeepSeek API advisory-review runner and live connectivity verifier without faking DeepSeek output or treating advisory output as human/native/final review.

## Planned Deliverables
- Real DeepSeek API advisory runner.
- DeepSeek API connectivity verifier.
- DeepSeek API advisory integration document.
- DeepSeek API advisory integration restore receipt.
- Updated controls, planning record, and handoff.

## Current API Integration Posture
- `DEEPSEEK_API_KEY`: detected in process environment without printing.
- API base URL: `https://api.deepseek.com`.
- OpenAI-compatible endpoint: `/chat/completions`.
- Preferred model: `deepseek-v4-flash`.
- Fallback model: `deepseek-v4-pro`.
- Live connectivity test: PASS.
- Observed successful models during live verifier runs: `deepseek-v4-flash`; `deepseek-v4-pro` via fallback after one preferred-model empty-content response..
- Test output path: `C:\Users\Veristio Writer\AppData\Local\Temp\veristio_deepseek_api_connectivity\deepseek_connectivity_output.md`.

## Current Packet Posture
- Selected candidate: `CANDIDATE-001` - Human Creativity + AI Synthesis.
- Selected chapter: Chapter 1 - Work Changed Before Most People Noticed.
- English state: `EN_TRANSLATION_READY_WITH_CONDITIONS`.
- English lock version: `BOOK1-CH01-EN-LOCK-V1`.
- Locked source commit: `bd0441d4a5cf8e5862a61421b3d515eb079afee4`.
- Current Spanish draft: `BOOK_1_CHAPTER_1_SPANISH_DRAFT_V3.md`.
- Prior non-API-backed DeepSeek advisory artifact: recorded with provenance warning and should be superseded by a real API-backed advisory review in the next corridor.
- Human review: pending.
- Native-language review: pending.
- Technical review: pending.
- Final sync/proof review: pending.
- Metadata/ISBN/release gates: pending.
- Publication/release boundary: blocked.
- Required next corridor: `RERUN_BOOK_1_CHAPTER_1_SPANISH_DRAFT_V3_REAL_DEEPSEEK_ADVISORY_REVIEW_V1`.

## Risk Controls
- Stop on path, branch, remote, or HEAD mismatch.
- Stop if `DEEPSEEK_API_KEY` is missing for real API review work.
- Stop if live DeepSeek API response cannot be obtained.
- Never print, write, or commit the API key.
- Do not fake DeepSeek output.
- Do not call internal model output DeepSeek.
- Do not claim human/native/final review completion from advisory output.
- Do not claim Spanish publication readiness or release approval.
- Stop on verifier failures unless explicitly following the API-key/network repair path.
