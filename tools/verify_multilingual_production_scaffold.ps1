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

$requiredFiles = @(
    'README.md',
    'controls/CURRENT_WORKING_LANE.md',
    'controls/NEXT_IMPLEMENTATION_CORRIDOR.md',
    'controls/PHASE_LEDGER.md',
    'docs/governance/PROJECT_CHARTER.md',
    'docs/governance/DECISION_REGISTER.md',
    'docs/governance/OPEN_QUESTIONS_REGISTER.md',
    'docs/planning/PROJECT_PLANNING_RECORD.md',
    'handoff/ARRIVAL_ANCHOR_CURRENT.md',
    'docs/governance/receipts/MULTILINGUAL_PRODUCTION_PROJECT_BIRTH_RECEIPT_V1.md',
    'tools/verify_multilingual_production_scaffold.ps1',
    'tests/README.md'
)

$requiredDirs = @(
    'docs/governance/receipts',
    'tests',
    'tools'
)

$requiredTranslationFiles = @(
    'docs/translation/TRANSLATION_STRATEGY_V1.md',
    'docs/translation/LANGUAGE_EDITION_REGISTER_V1.md',
    'docs/translation/BILINGUAL_TERMINOLOGY_REGISTER_EN_ES_V1.md',
    'docs/translation/TRANSLATION_CHANGE_SYNC_LOG_V1.md',
    'docs/translation/TRANSLATION_QA_CHECKLIST_V1.md',
    'docs/translation/MULTILINGUAL_METADATA_ISBN_MATRIX_V1.md',
    'docs/translation/SPANISH_PILOT_READINESS_GATE_V1.md',
    'docs/translation/CHAPTER_TRANSLATION_TRACKER_TEMPLATE_V1.csv',
    'docs/translation/CHAPTER_TRANSLATION_TRACKER_TEMPLATE_V1.md',
    'docs/translation/TRANSLATION_OPERATIONAL_FRONT_MATTER_V1.md'
)

foreach ($file in $requiredFiles) {
    Assert-Exists -Path (Join-Path $repoRoot $file) -Label 'Required scaffold file'
}

foreach ($dir in $requiredDirs) {
    $fullDir = Join-Path $repoRoot $dir
    if (-not (Test-Path -LiteralPath $fullDir -PathType Container)) {
        Add-Failure "Required directory missing: $fullDir"
    }
}

foreach ($file in $requiredTranslationFiles) {
    Assert-Exists -Path (Join-Path $repoRoot $file) -Label 'Required translation file'
}

$doctrineFile = Join-Path $repoRoot 'docs/translation/TRANSLATION_STRATEGY_V1.md'
$requiredDoctrinePhrases = @(
    'Parallel Trailing Localization',
    'English remains the canonical source-of-truth edition.',
    'Translated editions, starting with Spanish, may begin only after chapters reach a defined translation-ready stage.',
    'Spanish trails English by approved chapter locks rather than chasing rough drafts.',
    'Each translated edition is a separate product edition with its own ISBN, metadata, proof, and release approval.'
)

foreach ($phrase in $requiredDoctrinePhrases) {
    Assert-FileContains -File $doctrineFile -Needle $phrase -Label 'Doctrine check'
}

$requiredStates = @(
    'EN_DRAFTING',
    'EN_REVIEW',
    'EN_TRANSLATION_READY',
    'ES_TRANSLATION_DRAFT',
    'ES_TERMINOLOGY_REVIEW',
    'ES_NATIVE_REVIEW',
    'ES_TECHNICAL_REVIEW',
    'ES_SYNC_PENDING',
    'ES_PUBLICATION_READY'
)

foreach ($state in $requiredStates) {
    Assert-FileContains -File $doctrineFile -Needle $state -Label 'Chapter state check'
}

$trackerCsv = Join-Path $repoRoot 'docs/translation/CHAPTER_TRANSLATION_TRACKER_TEMPLATE_V1.csv'
if (Test-Path -LiteralPath $trackerCsv) {
    $firstLine = (Get-Content -LiteralPath $trackerCsv -TotalCount 1)
    $headerFields = $firstLine.Split(',')

    $requiredTrackerFields = @(
        'book_id',
        'book_title',
        'source_language',
        'target_language',
        'chapter_number',
        'chapter_title',
        'english_state',
        'english_lock_version',
        'english_translation_ready_date',
        'translation_state',
        'translator_or_ai_source',
        'terminology_review_status',
        'native_review_status',
        'technical_review_status',
        'sync_status',
        'metadata_status',
        'isbn_status',
        'proof_status',
        'release_gate',
        'notes'
    )

    foreach ($field in $requiredTrackerFields) {
        if ($headerFields -notcontains $field) {
            Add-Failure "Tracker field missing from CSV header: $field"
        }
    }
} else {
    Add-Failure "Tracker CSV missing: $trackerCsv"
}

$frontMatterFile = Join-Path $repoRoot 'docs/translation/TRANSLATION_OPERATIONAL_FRONT_MATTER_V1.md'
$requiredFrontMatterFields = @(
    'surface_id',
    'doctrine',
    'source_language',
    'target_language',
    'canonical_source_edition',
    'chapter_state',
    'source_lock_version',
    'translation_state',
    'sync_required',
    'final_release_allowed',
    'isbn_required',
    'metadata_required',
    'proof_required',
    'authority_boundary'
)

foreach ($field in $requiredFrontMatterFields) {
    Assert-FileContains -File $frontMatterFile -Needle ($field + ':') -Label 'Front matter field check'
}

$tempCodexPath = ('C:' + '\Users\Veristio Writer\Documents\Codex\2026-05-23\veristio-press-multilingual-production-lane-parallel')
$allProjectFiles = Get-ChildItem -LiteralPath $repoRoot -Recurse -File | Where-Object {
    $_.FullName -notlike '*\\.git\\*'
}

foreach ($file in $allProjectFiles) {
    $content = Get-Content -LiteralPath $file.FullName -Raw
    if ($content -match [regex]::Escape($tempCodexPath)) {
        Add-Failure "Forbidden temp path reference found in: $($file.FullName)"
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
