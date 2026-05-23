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

$packetDir = Join-Path $repoRoot 'docs/packets/book_1_human_creativity_ai_synthesis'
$packetFile = Join-Path $packetDir 'BOOK_1_SPANISH_PILOT_PACKET_PREPARATION_V1.md'
$chapterSelectionFile = Join-Path $packetDir 'BOOK_1_SPANISH_PILOT_CHAPTER_SELECTION_V1.md'
$gapLogFile = Join-Path $packetDir 'BOOK_1_SPANISH_PILOT_GAP_LOG_V1.md'
$intakeDecisionFile = Join-Path $packetDir 'BOOK_1_SPANISH_PILOT_INTAKE_DECISION_V1.md'
$trackerFile = Join-Path $packetDir 'BOOK_1_SPANISH_CHAPTER_TRANSLATION_TRACKER_V1.md'
$syncLogFile = Join-Path $packetDir 'BOOK_1_SPANISH_CHANGE_SYNC_LOG_V1.md'
$receiptFile = Join-Path $repoRoot 'docs/governance/receipts/BOOK_1_SPANISH_PILOT_TRANSLATION_PACKET_PREPARATION_RECEIPT_V1.md'

$requiredFiles = @(
    @{ Path = $packetFile; Label = 'Book 1 packet preparation file' },
    @{ Path = $chapterSelectionFile; Label = 'Book 1 chapter selection file' },
    @{ Path = $gapLogFile; Label = 'Book 1 gap log file' },
    @{ Path = $intakeDecisionFile; Label = 'Book 1 intake decision file' },
    @{ Path = $trackerFile; Label = 'Book 1 tracker instance' },
    @{ Path = $syncLogFile; Label = 'Book 1 change-sync instance' },
    @{ Path = $receiptFile; Label = 'Book 1 packet preparation receipt' }
)

foreach ($item in $requiredFiles) {
    Assert-Exists -Path $item.Path -Label $item.Label
}

$requiredPacketFields = @(
    'packet_id:',
    'source_book_id:',
    'source_book_title:',
    'source_repo_path:',
    'source_remote_url:',
    'source_branch:',
    'source_commit:',
    'selected_chapter_path_or_status:',
    'chapter_number:',
    'chapter_title:',
    'source_language:',
    'target_language:',
    'english_state:',
    'english_lock_version:',
    'translation_ready_date_or_status:',
    'glossary_version_or_gap:',
    'claims_status:',
    'citation_status:',
    'figures_tables_status:',
    'permissions_rights_status:',
    'metadata_isbn_status:',
    'reviewer_availability_status:',
    'receiving_translation_tracker:',
    'authority_boundary:',
    'intake_decision:',
    'next_required_action:',
    'notes:'
)

foreach ($field in $requiredPacketFields) {
    Assert-FileContains -File $packetFile -Needle $field -Label 'Packet field check'
}

$requiredPacketPhrases = @(
    'source_repo_path: D:\Dev\CGPT\Projects\Veristio\Book 1 Human Creativity + AI',
    'source_branch: main',
    'source_commit: bd0441d4a5cf8e5862a61421b3d515eb079afee4',
    'Book 1 repo remains canonical for English manuscript text',
    'selected_chapter_path_or_status:',
    'HOLD_FOR_EN_TRANSLATION_READY'
)

foreach ($phrase in $requiredPacketPhrases) {
    Assert-FileContains -File $packetFile -Needle $phrase -Label 'Packet required phrase check'
}

$allowedDecisions = @(
    'READY_FOR_TRANSLATION_DRAFT_PACKET',
    'READY_WITH_CONDITIONS',
    'HOLD_FOR_EN_TRANSLATION_READY',
    'HOLD_FOR_SOURCE_OR_CLAIM_GAPS',
    'HOLD_FOR_GLOSSARY_REVIEW',
    'HOLD_FOR_REVIEWER_AVAILABILITY',
    'HOLD_FOR_METADATA_ISBN_READINESS'
)

if (Test-Path -LiteralPath $intakeDecisionFile) {
    $content = Get-Content -LiteralPath $intakeDecisionFile -Raw
    $match = [regex]::Match($content, '(?m)^## Decision\s*\r?\n([A-Z_]+)\s*$')
    if (-not $match.Success) {
        Add-Failure 'Intake decision file does not declare a decision under ## Decision.'
    } elseif ($allowedDecisions -notcontains $match.Groups[1].Value) {
        Add-Failure "Intake decision is not allowed: $($match.Groups[1].Value)"
    }
}

Assert-FileContains -File $chapterSelectionFile -Needle 'selected_candidate_path:' -Label 'Chapter selection check'
Assert-FileContains -File $gapLogFile -Needle 'BOOK1-ES-GAP-001' -Label 'Gap log check'
Assert-FileContains -File $receiptFile -Needle 'HOLD_FOR_EN_TRANSLATION_READY' -Label 'Receipt decision check'

$holdCorridor = 'VERISTIO_PRESS_BOOK_1_EN_TRANSLATION_READY_GAP_CLOSURE_V1'
$readyCorridor = 'VERISTIO_PRESS_BOOK_1_SPANISH_TRANSLATION_DRAFT_PACKET_V1'
$corridorFound = $false
foreach ($file in @($packetFile, $chapterSelectionFile, $gapLogFile, $intakeDecisionFile, $receiptFile)) {
    if (Test-Path -LiteralPath $file) {
        $content = Get-Content -LiteralPath $file -Raw
        if ($content -match [regex]::Escape($holdCorridor) -or $content -match [regex]::Escape($readyCorridor)) {
            $corridorFound = $true
        }
    }
}
if (-not $corridorFound) {
    Add-Failure 'Neither ready nor hold next corridor is present in packet preparation surfaces.'
}

$filesToScan = @(
    $packetFile,
    $chapterSelectionFile,
    $gapLogFile,
    $intakeDecisionFile,
    $trackerFile,
    $syncLogFile,
    $receiptFile
)

$translationStartedRegex = '(?i)(Spanish translation has begun|Spanish translation began|translation execution started|Spanish draft created|ES_TRANSLATION_DRAFT\s*[:=]\s*(created|complete|started))'
$publicationReadyRegex = '(?i)(Spanish output is publication-ready|Spanish edition is publication-ready|ES_PUBLICATION_READY\s*[:=]\s*(created|complete|passed|ready))'
$authorityTransferRegex = '(?i)(Multilingual Production repo owns.*canonical English manuscript|this repo owns.*Book 1 canonical English manuscript)'

foreach ($file in $filesToScan) {
    if (-not (Test-Path -LiteralPath $file)) {
        continue
    }

    $content = Get-Content -LiteralPath $file -Raw
    if ($content -match $translationStartedRegex) {
        Add-Failure "File appears to claim Spanish translation has begun: $file"
    }
    if ($content -match $publicationReadyRegex) {
        Add-Failure "File appears to claim Spanish publication readiness: $file"
    }
    if ($content -match $authorityTransferRegex) {
        Add-Failure "File appears to transfer Book 1 canonical English manuscript authority: $file"
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
