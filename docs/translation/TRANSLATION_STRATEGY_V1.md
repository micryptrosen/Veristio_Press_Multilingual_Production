# Translation Strategy v1

## Purpose
Define a reusable Veristio Press translation/localization production lane.

## Doctrine
Parallel Trailing Localization.

English remains the canonical source-of-truth edition. Translated editions, starting with Spanish, may begin only after chapters reach a defined translation-ready stage. Spanish trails English by approved chapter locks rather than chasing rough drafts. Each translated edition is a separate product edition with its own ISBN, metadata, proof, and release approval.

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

## Core Workflow
English chapter stable/translation-ready
-> Spanish draft translation
-> terminology/native-language review
-> technical review
-> hold until English final-lock
-> final sync/proof/layout/metadata release.

## Governance Rule
Localized editions are separate product editions with their own ISBN, metadata, cover copy, proof, and release approval.

## Translation Entry Gate
Translation begins only when:
- English chapter state is EN_TRANSLATION_READY.
- English lock version is recorded.
- Scope package includes chapter text plus figures/tables/references.