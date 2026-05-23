# Contract Alignment Handshake Disposition Chain V1

## Purpose
Record the Publishing Core contract-alignment disposition chain for multilingual and localization obligations in governed repo markdown. This file exists so the multilingual requirement is repo truth, not chat memory, external notes, or an implied pillar-specific assumption.

## Mandatory Multilingual Contract Dimension
Multilingual/localization is a cross-cutting Publishing Core contract dimension, not isolated to the Multilingual Production pillar.

Every Publishing Core contract handshake, disposition chain, next-action decision, status report, and release gate must evaluate language and localization impact before any edition or format is treated as ready for publication, distribution, upload, or release.

## Authority Boundary
- Book repos own canonical source manuscripts, source readiness, source-lock records, claims, citations, and permissions.
- The Multilingual Production repo owns translation/localization process, language-edition governance, translation packet lineage, terminology/glossary coordination, review routing, metadata/ISBN coordination status, multilingual QA/advisory boundaries, and release-gate tracking.
- A translation packet is admitted workflow evidence, not an authority transfer from the source Book repo.
- No language edition is publication-ready unless required review, metadata, permission, source-lock, QA, proof, format, and release gates are explicitly satisfied.

## Disposition Chain Fields
| field | contract requirement |
|---|---|
| source language | Every handshake must record the source language for the source edition or source packet. |
| target language | Every localized or translated edition must record the target language. |
| locale | Every localized or translated edition must record a locale or state that locale is pending. |
| translation status | Every translated edition must state draft, review, hold, deferred, or release-gated status without implying final approval. |
| terminology/glossary dependency | Every translated edition must record terminology/glossary dependency status and unresolved term decisions. |
| native-language reviewer state | Every translated edition must record named reviewer assignment, reviewer pending, review held, or documented review status. |
| localization notes | Every translated edition must capture localization notes for title treatment, register, cultural fit, technical ambiguity, and format impacts. |
| source-lock version used for translation | Every translation packet must record the source-lock version used for translation, or hold intake until the lock is available. |
| translation packet lineage | Every translation packet must trace source repo, source commit, lock version, packet id, draft/review artifact, and receiving tracker lineage. |
| metadata language/edition fields | Every edition/format must record language, locale, edition id, format, ISBN status, metadata status, proof status, and release approval status. |
| multilingual QA/advisory boundaries | Advisory or internal review cannot substitute for documented native-language, technical, final sync/proof, metadata, ISBN, permission, and release gates. |
| publication gates per language, edition, and format | Each language, edition, and format must independently pass source-lock, permissions, metadata, ISBN, QA, proof, and release approval gates. |
| blocked/deferred states for missing language review | Missing language review must produce `HOLD_FOR_NATIVE_REVIEWER_ASSIGNMENT`, `BLOCKED_MISSING_NATIVE_LANGUAGE_REVIEW`, or `DEFERRED_LANGUAGE_REVIEW`, not release approval. |

## Book 1 Spanish Contract Disposition
| contract subject | current disposition | evidence and boundary |
|---|---|---|
| Book 1 Spanish | `FUTURE_PILOT_CANDIDATE_ONLY` | Publishing Core contract alignment must treat Book 1 Spanish as future pilot candidate only until required language review, metadata, permission, source-lock, QA, proof, format, and release gates are explicitly satisfied. |
| Multilingual packet posture | `ES_TRANSLATION_DRAFT_V2_NATIVE_REVIEW_HELD_FOR_OPERATOR_SELECTION` | The Multilingual Production repo may maintain draft/review workflow artifacts, but those artifacts do not create Publishing Core publication readiness. |
| source language | English | Canonical manuscript remains in the Book 1 repo. |
| target language | Spanish | Spanish is the pilot target language for workflow proof, not a release-approved edition. |
| locale | `es` / neutral Spanish pending reviewer decision | Locale and regional neutrality remain reviewer/operator decisions. |
| source-lock version used for translation | `BOOK1-CH01-EN-LOCK-V1` | Chapter 1 translation packet lineage uses this lock; post-lock English changes require change-sync logging. |
| translation packet lineage | Book 1 repo -> locked Chapter 1 source commit -> Multilingual packet -> Draft V2 -> native-review hold | Lineage is process evidence only and does not transfer canonical manuscript authority. |
| native-language reviewer state | `HOLD_FOR_NATIVE_REVIEWER_ASSIGNMENT` | No named native-language reviewer is assigned in repo truth. |
| terminology/glossary dependency | `SEEDED_INTERNAL_REVISIONS_APPLIED_NAMED_REVIEW_PENDING` | Terminology seed and internal pass exist, but named terminology/native review remains pending. |
| metadata language/edition fields | Pending per Spanish edition and format | ISBN, metadata, proof, permissions, and release approval remain pending for every Spanish format. |

## Chain Rule
If a handshake disposition touches publishing, metadata, editions, distribution, review, release, upload, or format readiness, it must ask: What source language, target language, locale, translation status, terminology dependency, native-language review state, packet lineage, source-lock version, metadata language/edition fields, QA boundary, and per-language/edition/format release gates apply?

If the answer is incomplete, the contract disposition must remain blocked or deferred.
