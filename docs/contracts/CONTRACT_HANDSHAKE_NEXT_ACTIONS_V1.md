# Contract Handshake Next Actions V1

## Purpose
Define next actions for Publishing Core contract handshakes when multilingual/localization requirements affect disposition, release, metadata, or edition readiness.

## Mandatory Multilingual Contract Dimension
Multilingual/localization is a cross-cutting Publishing Core contract dimension, not isolated to the Multilingual Production pillar.

These next actions apply to Publishing Core contract alignment even when the operational work lives in another pillar or repo. The Multilingual Production repo remains the workflow/governance owner for translation packet lineage and review controls, but Publishing Core must carry the multilingual requirement in its own contract reasoning.

## Required Next Actions
| action id | action | owner surface | required result |
|---|---|---|---|
| `MCA-001` | Add source language, target language, and locale/pending-locale fields to any contract handshake that affects editions or release. | Contract handshake/status surfaces | Language impact cannot be omitted. |
| `MCA-002` | Record translation status for each translated/localized edition. | Contract disposition chain | Draft, review, hold, deferred, or gate state is explicit. |
| `MCA-003` | Record terminology/glossary dependency and unresolved term decisions. | Reason map and packet lineage | Terminology cannot be silently treated as complete. |
| `MCA-004` | Record native-language reviewer state. | Reviewer assignment/status surfaces | Missing reviewer creates a blocked/deferred state. |
| `MCA-005` | Record localization notes for title, register, locale, cultural fit, technical ambiguity, and format impacts. | Contract and packet notes | Localization risk is visible before release decisions. |
| `MCA-006` | Record source-lock version used for translation. | Translation packet lineage | Translation cannot float against unstated source text. |
| `MCA-007` | Record translation packet lineage from source repo/commit/lock through packet, draft/review artifact, and tracker. | Contract alignment chain | Packet evidence is traceable without transferring manuscript authority. |
| `MCA-008` | Record metadata language/edition fields per language, edition, and format. | Metadata/ISBN matrix/status | ISBN, metadata, proof, and release status are format-specific. |
| `MCA-009` | Preserve multilingual QA/advisory boundaries. | QA/status/handoff | Internal/advisory work does not replace named reviewer or release gates. |
| `MCA-010` | Require publication gates per language, edition, and format. | Publishing Core contract disposition | Each edition/format must pass its own gates before release. |
| `MCA-011` | Use blocked/deferred states for missing language review. | Status/handoff | Missing review cannot become implied readiness. |
| `MCA-012` | Carry Book 1 Spanish as `FUTURE_PILOT_CANDIDATE_ONLY` in Publishing Core contract alignment. | Status and receipt | Book 1 Spanish remains future-only for Publishing Core release reasoning. |

## Book 1 Spanish Next Action Posture
| topic | current action state | next action |
|---|---|---|
| Book 1 Spanish | `FUTURE_PILOT_CANDIDATE_ONLY` | Keep Publishing Core contract disposition future-only until gates are explicitly satisfied. |
| source language | English recorded | Preserve Book 1 as canonical English source owner. |
| target language | Spanish recorded | Keep Spanish as pilot target language, not release approval. |
| locale | Neutral Spanish/pending reviewer decision | Confirm locale/regional-neutrality with real native-language reviewer later. |
| translation status | `ES_TRANSLATION_DRAFT_V2_NATIVE_REVIEW_HELD_FOR_OPERATOR_SELECTION` | Continue reviewer-selection/native-review execution corridor. |
| terminology/glossary dependency | Seeded/internal pass pending named review | Route terminology decisions to named reviewer/operator before final language readiness. |
| native-language reviewer state | `HOLD_FOR_NATIVE_REVIEWER_ASSIGNMENT` | Select and document a real native-language reviewer or keep held. |
| localization notes | Open for title/register/cultural/technical review | Carry notes into native review instructions and later technical review. |
| source-lock version used for translation | `BOOK1-CH01-EN-LOCK-V1` | Reconcile post-lock source changes through change-sync before release reasoning. |
| translation packet lineage | Recorded through Draft V2 and reviewer copy export | Keep lineage in any downstream review or handoff. |
| metadata language/edition fields | Pending for Spanish edition and each format | Do not close metadata/ISBN/proof/release gates without explicit evidence. |
| multilingual QA/advisory boundaries | Internal review only; named reviews pending | Maintain boundary in every review and status artifact. |
| publication gates per language, edition, and format | Open | Block publication/release until all gates pass for the specific edition/format. |
| blocked/deferred states for missing language review | Active reviewer hold | Use `HOLD_FOR_NATIVE_REVIEWER_ASSIGNMENT` until reviewer evidence exists. |

## Next Corridor
`VERISTIO_PRESS_BOOK_1_SPANISH_REVIEWER_SELECTION_OR_NATIVE_REVIEW_EXECUTION_V1`

## Boundary
This file defines next actions only. It does not claim native-language review completion, human review completion, technical review completion, final sync/proof completion, metadata completion, ISBN completion, permission clearance, publication readiness, release approval, or upload readiness for any language edition.
