# Status Current

## Status Date
2026-05-23

## Current Contract Correction
Multilingual/localization is a cross-cutting Publishing Core contract dimension, not isolated to the Multilingual Production pillar.

This status file records the multilingual requirement directly in governed repo markdown. The requirement is not satisfied by chat memory, external notes, or the existence of the Multilingual Production pillar alone.

## Publishing Core Multilingual Status Fields
| field | current status |
|---|---|
| source language | English for Book 1 Chapter 1 source evidence. |
| target language | Spanish for the Book 1 pilot workflow. |
| locale | `es` / neutral Spanish pending real native-language reviewer decision. |
| translation status | `ES_TRANSLATION_DRAFT_V2_NATIVE_REVIEW_HELD_FOR_OPERATOR_SELECTION`; draft workflow exists, release readiness does not. |
| terminology/glossary dependency | `SEEDED_INTERNAL_REVISIONS_APPLIED_NAMED_REVIEW_PENDING`; terminology/glossary dependency remains open. |
| native-language reviewer state | `HOLD_FOR_NATIVE_REVIEWER_ASSIGNMENT`; no named native-language reviewer is assigned in repo truth. |
| localization notes | Title treatment, register, regional neutrality, cultural fit, and technical ambiguity remain review topics. |
| source-lock version used for translation | `BOOK1-CH01-EN-LOCK-V1`; locked source commit `bd0441d4a5cf8e5862a61421b3d515eb079afee4`. |
| translation packet lineage | Book 1 repo -> Chapter 1 lock -> Multilingual packet -> Spanish Draft V2 -> reviewer copy export -> native-review hold. |
| metadata language/edition fields | Spanish metadata, ISBN, proof, permission, and release fields remain pending per edition and format. |
| multilingual QA/advisory boundaries | Internal/advisory passes do not replace named native-language, technical, final sync/proof, metadata, ISBN, permission, or release gates. |
| publication gates per language, edition, and format | Open for every Spanish edition/format; each must pass separately. |
| blocked/deferred states for missing language review | `HOLD_FOR_NATIVE_REVIEWER_ASSIGNMENT`; missing reviewer blocks native review result and release reasoning. |
| Book 1 Spanish | `FUTURE_PILOT_CANDIDATE_ONLY` for Publishing Core contract alignment. |

## Current Corridor
`VERISTIO_PRESS_BOOK_1_SPANISH_REVIEWER_SELECTION_OR_NATIVE_REVIEW_EXECUTION_V1`

## Publication Boundary
No language edition is publication-ready unless required review, metadata, permission, source-lock, QA, proof, format, and release gates are explicitly satisfied. Book 1 Spanish has not satisfied those gates.
