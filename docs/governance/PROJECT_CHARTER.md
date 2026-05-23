# Project Charter

## Project Name
Veristio Press Multilingual Production

## Purpose
Own the reusable multilingual publishing doctrine, language-edition governance, translation/localization production workflows, chapter tracking, metadata/ISBN matrices, and Spanish pilot readiness controls for Veristio Press books.

## Governing Doctrine
Parallel Trailing Localization.

English remains the canonical source-of-truth edition. Translated editions, starting with Spanish, may begin only after chapters reach a defined translation-ready stage. Spanish trails English by approved chapter locks rather than chasing rough drafts. Each translated edition is a separate product edition with its own ISBN, metadata, proof, and release approval.

## Required Workflow
English chapter stable/translation-ready
-> Spanish draft translation
-> terminology/native-language review
-> technical review
-> hold until English final-lock
-> final sync/proof/layout/metadata release.

## Required Chapter States
- EN_DRAFTING
- EN_REVIEW
- EN_TRANSLATION_READY
- ES_TRANSLATION_DRAFT
- ES_TERMINOLOGY_REVIEW
- ES_NATIVE_REVIEW
- ES_TECHNICAL_REVIEW
- ES_SYNC_PENDING
- ES_PUBLICATION_READY

## Authority Boundary
- English edition is canonical source authority.
- Localized editions cannot override English source intent.
- Localized editions require independent release approval.

## Success Criteria
- Required repository scaffold exists and is verified.
- Translation lane templates are reusable and complete.
- Verifier gates pass before publication-operations use.