# Book Repo Translation Handoff Contract v1

## Purpose
Define the authority boundary and intake contract between a source Book repo and this Multilingual Production repo for Spanish pilot execution.

## Authority Boundary (Non-Negotiable)
- Source Book repo remains canonical for the English manuscript.
- This repository owns translation/localization process, language-edition governance, trackers, metadata/ISBN coordination, QA gates, and pilot-readiness controls.
- Translation packet is an exported/admitted package for localization intake, not an authority transfer.
- This repository must not directly mutate any Book repo content, history, branch, or release state.

## Translation Intake Preconditions
- Chapter must be marked `EN_TRANSLATION_READY` before intake.
- English lock version must be included with the intake packet.
- Source repo path, branch, commit, and chapter path must be recorded.
- Unresolved claims/source/citation issues must be declared in the packet.

## Packet and Admission Rules
- Intake uses `docs/integration/BOOK_REPO_TRANSLATION_PACKET_TEMPLATE_V1.md`.
- Packet admission authorizes translation work only for the declared lock and scope.
- Post-intake English changes must be logged through translation change sync.
- Change sync authority references `docs/translation/TRANSLATION_CHANGE_SYNC_LOG_V1.md`.

## Release and Publication Rules
- Spanish output cannot be released until final sync, proof, metadata, ISBN, and release gate pass.
- Translated edition has separate ISBN, metadata, proof, and release approval from the source English edition.
- `ES_PUBLICATION_READY` is blocked when any required sync/proof/metadata/ISBN gate is open.

## Claims, Sources, and Citations Governance
- Unresolved claims/source/citation issues remain governed by the source Book repo unless separately admitted into this repo's translation governance lane.
- Translation notes may reference unresolved items but may not override source-claim authority.

## Non-Mutation Rule for Source Book Repos
- Do not edit files in source Book repos from this repo workflow.
- Do not open pull requests against source Book repos from this repo workflow.
- Do not treat packet admission as permission to rewrite canonical English manuscript text.

## Acceptance
This contract is active for the Spanish pilot and all candidate books admitted under this tranche until superseded by a higher-version contract.
