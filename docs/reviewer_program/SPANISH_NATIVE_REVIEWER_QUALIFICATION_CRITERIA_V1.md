# Spanish Native Reviewer Qualification Criteria V1

## Purpose

Define qualification criteria for a real native-language reviewer for the Book 1 Spanish pilot. These criteria support reviewer selection; they do not assign a reviewer or perform a review.

## Required Qualification Criteria

| criterion_id | criterion | required evidence | acceptance standard | rejection or hold trigger |
|---|---|---|---|---|
| ES-NR-QC-001 | Native Spanish fluency | Self-attestation, professional background, education, or operator-known evidence | Reviewer can identify unnatural Spanish, awkward literal phrasing, register issues, and meaning shifts. | Fluency cannot be established. |
| ES-NR-QC-002 | Locale or neutrality fit | Acknowledgement of neutral Spanish or selected locale expectation | Reviewer can flag region-specific wording and suggest neutral alternatives when needed. | Reviewer cannot support neutral or selected-locale review. |
| ES-NR-QC-003 | Educational/workforce reader suitability | Sample review or relevant background | Reviewer can judge clarity for education, workforce, and general professional readers. | Reviewer cannot assess target audience fit. |
| ES-NR-QC-004 | Technical reading suitability | Sample review or background with AI/work/technology content | Reviewer can flag technical ambiguity without claiming final technical approval. | Reviewer cannot identify obvious technical-language risk. |
| ES-NR-QC-005 | Source-alignment discipline | Acknowledgement of locked-source boundary | Reviewer agrees not to alter Book 1 and to flag suspected source issues for escalation. | Reviewer expects to edit canonical English or rewrite beyond Spanish review scope. |
| ES-NR-QC-006 | Confidentiality/IP boundary | Signed or recorded acknowledgement | Reviewer agrees not to redistribute drafts, source excerpts, packets, or reviewer notes outside authorized channels. | Confidentiality/IP acknowledgement is refused. |
| ES-NR-QC-007 | AI-use boundary | Signed or recorded acknowledgement | Reviewer discloses any AI-assisted review use and does not upload confidential text into unauthorized tools. | AI-use boundary is refused or unclear. |
| ES-NR-QC-008 | Review documentation readiness | Agreement to complete checklist/findings | Reviewer can record name, date, scope, findings, and decision status. | Reviewer will not document the review. |

## Acceptance Criteria

A reviewer can be accepted only when all required criteria are met or an operator explicitly records a justified waiver. Any waiver must state why the risk is acceptable for native-language review and must preserve publication/release blocking.

## Rejection Criteria

Reject or hold the candidate if native fluency, confidentiality/IP, AI-use boundaries, documentation willingness, or source-authority discipline cannot be established.

## Signoff Fields Required At Assignment

- reviewer_name
- reviewer_role
- qualification_status
- native_fluency_basis
- locale_or_neutrality_acknowledgement
- confidentiality_ip_acknowledgement
- ai_use_boundary_acknowledgement
- sample_protocol_result
- assignment_date
- operator_name_or_role
- publication_release_block_acknowledgement

## Boundary

These criteria do not name a reviewer and do not claim native-language review has occurred. Publication remains blocked until documented native review occurs and all downstream release gates pass.

## Next Corridor

`VERISTIO_PRESS_BOOK_1_SPANISH_REVIEWER_SELECTION_OR_NATIVE_REVIEW_EXECUTION_V1`
