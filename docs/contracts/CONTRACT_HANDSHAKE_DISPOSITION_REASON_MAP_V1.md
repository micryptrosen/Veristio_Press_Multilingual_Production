# Contract Handshake Disposition Reason Map V1

## Purpose
Map disposition reasons for Publishing Core contract handshakes when multilingual/localization obligations are present. This reason map makes the multilingual requirement explicit in governed repo markdown.

## Mandatory Multilingual Contract Dimension
Multilingual/localization is a cross-cutting Publishing Core contract dimension, not isolated to the Multilingual Production pillar.

Contract handshakes must not classify multilingual concerns as optional downstream production chores when a decision affects an edition, format, metadata package, reader-facing surface, release, upload, distribution path, proof, or publication gate.

## Reason Map
| reason code | use when | required disposition |
|---|---|---|
| `MISSING_SOURCE_LANGUAGE` | Source language is absent from handshake, packet, or metadata. | Block or defer until source language is recorded. |
| `MISSING_TARGET_LANGUAGE_OR_LOCALE` | Target language or locale is absent for a translated/localized edition. | Block or defer until target language and locale/pending-locale status are recorded. |
| `TRANSLATION_STATUS_UNCLEAR` | Translation status does not distinguish draft, review, hold, deferred, or gated states. | Require explicit translation status before release reasoning. |
| `TERMINOLOGY_GLOSSARY_DEPENDENCY_OPEN` | Terminology/glossary dependency is missing, seeded only, or awaiting review. | Keep terminology/glossary dependency open and block final language readiness. |
| `NATIVE_LANGUAGE_REVIEWER_MISSING` | Native-language reviewer state is not assigned or not documented. | Use `HOLD_FOR_NATIVE_REVIEWER_ASSIGNMENT`, `BLOCKED_MISSING_NATIVE_LANGUAGE_REVIEW`, or `DEFERRED_LANGUAGE_REVIEW`. |
| `LOCALIZATION_NOTES_MISSING` | Title, register, cultural fit, technical ambiguity, or format-localization notes are absent. | Require localization notes or explicit no-impact rationale. |
| `SOURCE_LOCK_MISSING` | Source-lock version used for translation is absent or stale. | Hold translation packet intake or require change-sync reconciliation. |
| `PACKET_LINEAGE_INCOMPLETE` | Translation packet lineage lacks source repo, commit, lock, packet, draft, review, or tracker linkage. | Block publication reasoning until lineage is complete. |
| `METADATA_LANGUAGE_EDITION_FIELDS_PENDING` | Metadata language/edition fields, ISBN, format, or proof status is pending. | Keep edition/format release blocked. |
| `QA_ADVISORY_BOUNDARY_UNCLEAR` | Internal/advisory review might be mistaken for native-language, technical, final sync/proof, metadata, ISBN, permission, or release signoff. | Require multilingual QA/advisory boundaries before advancing. |
| `PER_LANGUAGE_FORMAT_GATE_OPEN` | Any publication gate per language, edition, or format is not explicitly satisfied. | Keep the affected language/edition/format blocked. |
| `BOOK_1_SPANISH_FUTURE_ONLY` | Book 1 Spanish is discussed in Publishing Core contract alignment. | Classify Book 1 Spanish as `FUTURE_PILOT_CANDIDATE_ONLY` until all required gates are explicitly satisfied. |

## Book 1 Spanish Reason Disposition
| subject | reason code | status | required handling |
|---|---|---|---|
| Book 1 Spanish | `BOOK_1_SPANISH_FUTURE_ONLY` | `FUTURE_PILOT_CANDIDATE_ONLY` | Do not treat the Spanish draft or review-copy export as publication readiness. |
| source language | `MISSING_SOURCE_LANGUAGE` not active | English recorded | Preserve Book 1 English canonical authority. |
| target language | `MISSING_TARGET_LANGUAGE_OR_LOCALE` partially open | Spanish recorded; locale remains neutral/pending reviewer decision | Keep locale notes in review packet. |
| translation status | `TRANSLATION_STATUS_UNCLEAR` not active | `ES_TRANSLATION_DRAFT_V2_NATIVE_REVIEW_HELD_FOR_OPERATOR_SELECTION` | Draft exists only for review routing. |
| terminology/glossary dependency | `TERMINOLOGY_GLOSSARY_DEPENDENCY_OPEN` | Open/pending named review | Do not close terminology readiness without documented review. |
| native-language reviewer state | `NATIVE_LANGUAGE_REVIEWER_MISSING` | `HOLD_FOR_NATIVE_REVIEWER_ASSIGNMENT` | Select/document real reviewer before native review can occur. |
| localization notes | `LOCALIZATION_NOTES_MISSING` partially open | Notes exist but remain reviewer/operator dependent | Keep title/register/cultural/technical ambiguity questions open. |
| source-lock version used for translation | `SOURCE_LOCK_MISSING` not active for Chapter 1 | `BOOK1-CH01-EN-LOCK-V1` | Use change sync for post-lock source changes. |
| translation packet lineage | `PACKET_LINEAGE_INCOMPLETE` not active for current packet | Packet lineage recorded through Draft V2 and native-review hold | Preserve lineage in downstream handoff. |
| metadata language/edition fields | `METADATA_LANGUAGE_EDITION_FIELDS_PENDING` | Pending | ISBN, metadata, proof, permissions, and release gates remain blocked per Spanish format. |
| multilingual QA/advisory boundaries | `QA_ADVISORY_BOUNDARY_UNCLEAR` controlled | Advisory/internal review is not final review | Keep human/native/technical/final gates pending. |
| publication gates per language, edition, and format | `PER_LANGUAGE_FORMAT_GATE_OPEN` | Open | No language edition or format may advance without explicit gate satisfaction. |
| blocked/deferred states for missing language review | `NATIVE_LANGUAGE_REVIEWER_MISSING` | Active hold | Use reviewer-pending states, not release states. |

## Reason Rule
A contract handshake reason cannot be closed by silence. If source language, target language, locale, translation status, terminology/glossary dependency, native-language reviewer state, localization notes, source-lock version used for translation, translation packet lineage, metadata language/edition fields, multilingual QA/advisory boundaries, or publication gates per language, edition, and format are missing, the disposition must state the blocked/deferred state.
