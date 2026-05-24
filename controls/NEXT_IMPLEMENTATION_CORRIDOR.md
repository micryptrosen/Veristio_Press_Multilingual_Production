# Next Implementation Corridor

## Corridor Goal
RERUN_BOOK_1_CHAPTER_1_SPANISH_DRAFT_V3_REAL_DEEPSEEK_ADVISORY_REVIEW_V1

## Readiness Source
- DeepSeek API integration: `docs/integration/DEEPSEEK_API_ADVISORY_INTEGRATION_V1.md`
- Runner: `tools/deepseek_advisory_review.py`
- Connectivity verifier: `tools/verify_deepseek_api_connectivity.ps1`
- Integration receipt: `docs/governance/receipts/DEEPSEEK_API_ADVISORY_INTEGRATION_RESTORE_RECEIPT_V1.md`

## Verified API Configuration
- `DEEPSEEK_API_KEY` detected: yes
- API base URL: `https://api.deepseek.com`
- Endpoint: `/chat/completions`
- Preferred model: `deepseek-v4-flash`
- Fallback model: `deepseek-v4-pro`
- Observed successful models during live verifier runs: `deepseek-v4-flash`; `deepseek-v4-pro` via fallback after one preferred-model empty-content response.
- Real API call succeeded: yes

## Immediate Next Steps
1. Rerun Book 1 Chapter 1 Spanish Draft V3 advisory review using `tools/deepseek_advisory_review.py` and the real DeepSeek API.
2. Supersede the prior non-API-backed DeepSeek advisory artifact with a real API-backed advisory output or clearly mark the relationship in governance records.
3. Preserve Draft V3 unless the next corridor explicitly creates a follow-on advisory output only.
4. Do not create Draft V4 until the combined-advisory correction corridor is opened after real API-backed review.
5. Keep Claude and DeepSeek advisory inputs classified as advisory-only.
6. Keep native-language review held until a real named reviewer is selected and documented.
7. Keep final sync/proof, metadata/ISBN, proof, permission, QA, and release gates pending.
8. Keep publication/release blocked until human/native/final review and all release gates pass.

## Exit Criteria
- A real API-backed DeepSeek advisory review output is committed, or API failure is recorded honestly.
- No API key is printed, written, or committed.
- No Book 1 repo mutation occurs.
- Advisory inputs are not treated as human/native/final review.
- No publication/release readiness is claimed.
