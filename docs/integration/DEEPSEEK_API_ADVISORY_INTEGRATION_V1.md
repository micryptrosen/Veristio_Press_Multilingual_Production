# DeepSeek API Advisory Integration V1

## Purpose

Restore real DeepSeek API advisory review capability for Veristio Press Multilingual Production without faking DeepSeek output and without treating advisory output as human, native-language, final, publication, or release approval.

## API Configuration

| field | value |
|---|---|
| API key source | `DEEPSEEK_API_KEY` process environment variable |
| API base URL | `https://api.deepseek.com` |
| OpenAI-compatible endpoint | `/chat/completions` |
| preferred model | `deepseek-v4-flash` |
| fallback model | `deepseek-v4-pro` |
| runner | `tools/deepseek_advisory_review.py` |
| connectivity verifier | `tools/verify_deepseek_api_connectivity.ps1` |

## Runner Contract

`tools/deepseek_advisory_review.py` must:

- Read `DEEPSEEK_API_KEY` from the process environment.
- Use the OpenAI-compatible chat completions API at `https://api.deepseek.com`.
- Accept an input file path and output file path.
- Write model name, timestamp, prompt purpose, API base URL, endpoint, advisory boundary, and response body into output markdown.
- Fail clearly if the API key is missing.
- Fail clearly if the network/API call fails.
- Try `deepseek-v4-flash` first and `deepseek-v4-pro` as fallback.
- Never print, commit, or write the API key.
- Never claim native-language review, human review, final review, publication readiness, release approval, or upload readiness.
- Label DeepSeek output advisory-only.

## Connectivity Verification

`tools/verify_deepseek_api_connectivity.ps1` performs a tiny live API test using a temporary input/output directory outside the repo working tree. The verifier confirms:

- `DEEPSEEK_API_KEY` exists without printing it.
- A real DeepSeek API response is obtained.
- The output file exists.
- The output records the model and prompt purpose.
- The response body contains `REAL_DEEPSEEK_API_RESPONSE`.
- The output records the DeepSeek advisory-only boundary.
- The API key is not written to the output file.

## Verified Connectivity

- Connectivity status: `REAL_DEEPSEEK_API_CALL_SUCCEEDED`
- Observed successful models during live verifier runs: `deepseek-v4-flash`; `deepseek-v4-pro` via fallback after one preferred-model empty-content response.
- Test output path: `C:\Users\Veristio Writer\AppData\Local\Temp\veristio_deepseek_api_connectivity\deepseek_connectivity_output.md`
- Verification command: `powershell -ExecutionPolicy Bypass -File tools\verify_deepseek_api_connectivity.ps1`

## Advisory Boundary

DeepSeek API output is advisory-only. It is not human review, not native-language review, not technical review, not final review, not publication readiness, and not release approval. Book 1 Spanish publication/release remains blocked until required human/native/final review, metadata, ISBN, proof, permission, source-lock, QA, edition/format, and release gates pass.

## Operational Use

Future DeepSeek advisory review tranches should run the real API runner and commit only the resulting advisory output and governance records when the verifier proves a real API response was obtained.

## Next Corridor

`RERUN_BOOK_1_CHAPTER_1_SPANISH_DRAFT_V3_REAL_DEEPSEEK_ADVISORY_REVIEW_V1`
