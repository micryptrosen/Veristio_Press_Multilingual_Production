# Veristio Press Multilingual Production

Canonical project for reusable multilingual publishing doctrine, language-edition governance, translation/localization workflows, chapter tracking, metadata/ISBN matrices, and Spanish pilot readiness controls.

## Doctrine
Parallel Trailing Localization.

English remains the canonical source-of-truth edition. Translated editions, starting with Spanish, may begin only after chapters reach a defined translation-ready stage. Spanish trails English by approved chapter locks rather than chasing rough drafts. Each translated edition is a separate product edition with its own ISBN, metadata, proof, and release approval.

## Core Workflow
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

## Project Verification
Run:

```powershell
powershell -ExecutionPolicy Bypass -File tools/verify_multilingual_production_scaffold.ps1
```