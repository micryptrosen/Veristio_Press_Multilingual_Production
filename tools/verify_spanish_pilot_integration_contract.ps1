[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$failures = New-Object System.Collections.Generic.List[string]

function Add-Failure {
    param([string]$Message)
    $script:failures.Add($Message)
}

function Assert-Exists {
    param([string]$Path, [string]$Label)
    if (-not (Test-Path -LiteralPath $Path)) {
        Add-Failure "$Label missing: $Path"
    }
}

function Assert-FileContains {
    param(
        [string]$File,
        [string]$Needle,
        [string]$Label
    )

    if (-not (Test-Path -LiteralPath $File)) {
        Add-Failure "$Label file missing: $File"
        return
    }

    $content = Get-Content -LiteralPath $File -Raw
    if ($content -notmatch [regex]::Escape($Needle)) {
        Add-Failure "$Label missing phrase: $Needle"
    }
}

$requiredIntegrationFiles = @(
    'docs/integration/BOOK_REPO_TRANSLATION_HANDOFF_CONTRACT_V1.md',
    'docs/integration/SPANISH_PILOT_SELECTION_CRITERIA_V1.md',
    'docs/integration/BOOK_REPO_TRANSLATION_PACKET_TEMPLATE_V1.md',
    'docs/integration/TRANSLATION_READY_CHAPTER_INTAKE_CHECKLIST_V1.md',
    'docs/integration/PILOT_BOOK_CANDIDATE_REGISTER_V1.md',
    'docs/governance/receipts/SPANISH_PILOT_SELECTION_AND_INTEGRATION_CONTRACT_RECEIPT_V1.md'
)

foreach ($file in $requiredIntegrationFiles) {
    Assert-Exists -Path (Join-Path $repoRoot $file) -Label 'Required integration file'
}

$handoffFile = Join-Path $repoRoot 'docs/integration/BOOK_REPO_TRANSLATION_HANDOFF_CONTRACT_V1.md'
$requiredHandoffPhrases = @(
    'Source Book repo remains canonical for the English manuscript.',
    'This repository owns translation/localization process, language-edition governance, trackers, metadata/ISBN coordination, QA gates, and pilot-readiness controls.',
    'Translation packet is an exported/admitted package for localization intake, not an authority transfer.',
    'Chapter must be marked `EN_TRANSLATION_READY` before intake.',
    'English lock version must be included with the intake packet.',
    'Post-intake English changes must be logged through translation change sync.',
    'Spanish output cannot be released until final sync, proof, metadata, ISBN, and release gate pass.',
    'Unresolved claims/source/citation issues remain governed by the source Book repo unless separately admitted into this repo''s translation governance lane.',
    'Translated edition has separate ISBN, metadata, proof, and release approval from the source English edition.'
)

foreach ($phrase in $requiredHandoffPhrases) {
    Assert-FileContains -File $handoffFile -Needle $phrase -Label 'Handoff contract check'
}

$criteriaFile = Join-Path $repoRoot 'docs/integration/SPANISH_PILOT_SELECTION_CRITERIA_V1.md'
$requiredCriteriaPhrases = @(
    'English manuscript maturity',
    'Glossary readiness',
    'Claim/source stability',
    'Technical complexity',
    'Audience value for Spanish edition',
    'Expected education/workforce usefulness',
    'Formatting complexity',
    'Rights/metadata readiness',
    'Likelihood of becoming reusable process proof',
    'Risk level',
    'Reviewer availability'
)

foreach ($phrase in $requiredCriteriaPhrases) {
    Assert-FileContains -File $criteriaFile -Needle $phrase -Label 'Spanish pilot criteria check'
}

$packetFile = Join-Path $repoRoot 'docs/integration/BOOK_REPO_TRANSLATION_PACKET_TEMPLATE_V1.md'
$requiredPacketFields = @(
    'packet_id:',
    'source_book_id:',
    'source_book_title:',
    'source_repo_path:',
    'source_branch:',
    'source_commit:',
    'source_chapter_path:',
    'chapter_number:',
    'chapter_title:',
    'source_language:',
    'target_language:',
    'english_state:',
    'english_lock_version:',
    'translation_ready_date:',
    'glossary_version:',
    'claims_status:',
    'citation_status:',
    'figures_tables_status:',
    'permissions_rights_status:',
    'intended_output_format:',
    'receiving_translation_tracker:',
    'authority_boundary:',
    'notes:'
)

foreach ($field in $requiredPacketFields) {
    Assert-FileContains -File $packetFile -Needle $field -Label 'Packet template field check'
}

$intakeFile = Join-Path $repoRoot 'docs/integration/TRANSLATION_READY_CHAPTER_INTAKE_CHECKLIST_V1.md'
$requiredIntakePhrases = @(
    'Source repo path exists and is resolvable.',
    'Source commit is recorded.',
    'Chapter is `EN_TRANSLATION_READY` (entry gate satisfied).',
    'English lock version is recorded.',
    'Glossary terms are available or a terminology gap is logged.',
    'Unresolved claims/citations are explicitly marked.',
    'Figures/tables/captions are identified for localization handling.',
    'Permissions/rights issues are identified.',
    'Translation tracker row is created or explicitly ready for creation.',
    'Translation change sync log is ready for post-intake English updates.',
    'Final release is blocked until all release gates pass (final sync, proof, metadata, ISBN, release approval).'
)

foreach ($phrase in $requiredIntakePhrases) {
    Assert-FileContains -File $intakeFile -Needle $phrase -Label 'Intake checklist check'
}

$candidateRegisterFile = Join-Path $repoRoot 'docs/integration/PILOT_BOOK_CANDIDATE_REGISTER_V1.md'
Assert-FileContains -File $candidateRegisterFile -Needle '| candidate_id | book_title | book_repo_path | current_book_stage | english_maturity | glossary_readiness | source_claim_stability | technical_complexity | spanish_audience_value | formatting_complexity | metadata_isbn_readiness | reviewer_availability | risk_level | recommendation | notes |' -Label 'Candidate register header check'

$integrationFilesToScan = @(
    $handoffFile,
    $criteriaFile,
    $packetFile,
    $intakeFile,
    $candidateRegisterFile
)

$mutationImperativeRegex = '(?i)^\s*(?:[-*]|\d+\.)\s*(edit|modify|mutate|commit|push|open pull request|create pull request)\b.*\b(book repo|source repo)\b'
$allowedGuardRegex = '(?i)(do not|must not|never|prohibited|forbidden|cannot|mustn''t)'

foreach ($file in $integrationFilesToScan) {
    if (-not (Test-Path -LiteralPath $file)) {
        continue
    }

    $lines = Get-Content -LiteralPath $file
    for ($i = 0; $i -lt $lines.Count; $i++) {
        $line = $lines[$i]
        if ($line -match $mutationImperativeRegex -and $line -notmatch $allowedGuardRegex) {
            Add-Failure "Potential direct Book repo mutation instruction in $file line $($i + 1): $line"
        }
    }
}

$releaseAllowRegex = '(?i)(can be released|release is allowed|release approved|publication[- ]ready|es_publication_ready)'
$releaseGuardRegex = '(?i)(cannot|blocked|until|final sync|proof|metadata|isbn|release gate|release approval)'

foreach ($file in $integrationFilesToScan) {
    if (-not (Test-Path -LiteralPath $file)) {
        continue
    }

    $lines = Get-Content -LiteralPath $file
    for ($i = 0; $i -lt $lines.Count; $i++) {
        $line = $lines[$i]
        if ($line -match $releaseAllowRegex -and $line -notmatch $releaseGuardRegex) {
            Add-Failure "Potential premature publication-ready/release language without gates in $file line $($i + 1): $line"
        }
    }
}

if ($failures.Count -gt 0) {
    Write-Host 'VERIFICATION FAIL' -ForegroundColor Red
    foreach ($failure in $failures) {
        Write-Host "- $failure" -ForegroundColor Red
    }
    exit 1
}

Write-Host 'VERIFICATION PASS' -ForegroundColor Green
Write-Host "Repo root: $repoRoot"
exit 0
