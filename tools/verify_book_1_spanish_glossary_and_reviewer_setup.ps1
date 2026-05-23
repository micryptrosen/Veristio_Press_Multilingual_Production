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

function Normalize-CopyCheck {
    param([string]$Content)
    return (($Content -replace '\s+', ' ').Trim())
}

$packetDir = Join-Path $repoRoot 'docs/packets/book_1_human_creativity_ai_synthesis'
$terminologySeedFile = Join-Path $packetDir 'BOOK_1_SPANISH_TERMINOLOGY_SEED_V1.md'
$reviewerWorkflowFile = Join-Path $packetDir 'BOOK_1_SPANISH_REVIEWER_WORKFLOW_V1.md'
$glossaryGapLogFile = Join-Path $packetDir 'BOOK_1_SPANISH_GLOSSARY_GAP_LOG_V1.md'
$draftReadinessGateFile = Join-Path $packetDir 'BOOK_1_SPANISH_TRANSLATION_DRAFT_READINESS_GATE_V1.md'
$receiptFile = Join-Path $repoRoot 'docs/governance/receipts/BOOK_1_SPANISH_GLOSSARY_AND_REVIEWER_SETUP_RECEIPT_V1.md'
$terminologyRegisterFile = Join-Path $repoRoot 'docs/translation/BILINGUAL_TERMINOLOGY_REGISTER_EN_ES_V1.md'
$pilotGapLogFile = Join-Path $packetDir 'BOOK_1_SPANISH_PILOT_GAP_LOG_V1.md'
$trackerFile = Join-Path $packetDir 'BOOK_1_SPANISH_CHAPTER_TRANSLATION_TRACKER_V1.md'
$intakeDecisionFile = Join-Path $packetDir 'BOOK_1_SPANISH_PILOT_INTAKE_DECISION_V1.md'
$currentLaneFile = Join-Path $repoRoot 'controls/CURRENT_WORKING_LANE.md'
$nextCorridorFile = Join-Path $repoRoot 'controls/NEXT_IMPLEMENTATION_CORRIDOR.md'
$planningFile = Join-Path $repoRoot 'docs/planning/PROJECT_PLANNING_RECORD.md'
$handoffFile = Join-Path $repoRoot 'handoff/ARRIVAL_ANCHOR_CURRENT.md'

$requiredFiles = @(
    @{ Path = $terminologySeedFile; Label = 'Book 1 Spanish terminology seed' },
    @{ Path = $reviewerWorkflowFile; Label = 'Book 1 Spanish reviewer workflow' },
    @{ Path = $glossaryGapLogFile; Label = 'Book 1 Spanish glossary gap log' },
    @{ Path = $draftReadinessGateFile; Label = 'Book 1 Spanish translation draft readiness gate' },
    @{ Path = $receiptFile; Label = 'Book 1 Spanish glossary/reviewer setup receipt' }
)

foreach ($item in $requiredFiles) {
    Assert-Exists -Path $item.Path -Label $item.Label
}

Assert-FileContains -File $terminologyRegisterFile -Needle 'Book 1 Spanish Pilot Terminology Seed' -Label 'Terminology register Book 1 section check'
Assert-FileContains -File $terminologyRegisterFile -Needle 'BOOK_1_SPANISH_TERMINOLOGY_SEED_V1.md' -Label 'Terminology register seed reference check'

$requiredSeedTerms = @(
    'Human Creativity + AI Synthesis',
    'artificial intelligence',
    'AI',
    'human creativity',
    'synthesis',
    'advisory model',
    'canonical manuscript',
    'source-of-truth edition',
    'translation-ready',
    'English lock version',
    'change-sync log',
    'source-verified claim',
    'governed workflow',
    'Veristio Press',
    'Veristio',
    'reviewer workflow',
    'publication-readiness gate',
    'metadata/ISBN'
)

foreach ($term in $requiredSeedTerms) {
    Assert-FileContains -File $terminologySeedFile -Needle $term -Label 'Terminology seed required term check'
}

$requiredReviewerRoles = @(
    'terminology reviewer',
    'native-language reviewer',
    'technical reviewer',
    'final sync/proof reviewer'
)

foreach ($role in $requiredReviewerRoles) {
    Assert-FileContains -File $reviewerWorkflowFile -Needle $role -Label 'Reviewer workflow role check'
}

$allowedGateDecisions = @(
    'READY_FOR_TRANSLATION_DRAFT_PACKET',
    'READY_WITH_CONDITIONS',
    'HOLD_FOR_GLOSSARY_REVIEW',
    'HOLD_FOR_REVIEWER_AVAILABILITY',
    'HOLD_FOR_METADATA_ISBN_READINESS'
)

if (Test-Path -LiteralPath $draftReadinessGateFile) {
    $gateContent = Get-Content -LiteralPath $draftReadinessGateFile -Raw
    $match = [regex]::Match($gateContent, '(?m)^## Gate Decision\s*\r?\n([A-Z_]+)\s*$')
    if (-not $match.Success) {
        Add-Failure 'Draft readiness gate does not declare a decision under ## Gate Decision.'
    } elseif ($allowedGateDecisions -notcontains $match.Groups[1].Value) {
        Add-Failure "Draft readiness gate uses an unsupported decision: $($match.Groups[1].Value)"
    }
}

Assert-FileContains -File $terminologySeedFile -Needle 'Book 1 repo remains canonical for English manuscript text' -Label 'Terminology seed authority boundary check'
Assert-FileContains -File $reviewerWorkflowFile -Needle 'Book 1 remains canonical for English manuscript text' -Label 'Reviewer workflow authority boundary check'
Assert-FileContains -File $draftReadinessGateFile -Needle 'Book 1 remains canonical for English manuscript text' -Label 'Draft readiness authority boundary check'

$draftCorridor = 'VERISTIO_PRESS_BOOK_1_SPANISH_TRANSLATION_DRAFT_PACKET_V1'
$holdCorridor = 'VERISTIO_PRESS_BOOK_1_SPANISH_REVIEWER_ASSIGNMENT_V1'
$corridorFound = $false
foreach ($file in @($terminologySeedFile, $reviewerWorkflowFile, $glossaryGapLogFile, $draftReadinessGateFile, $receiptFile, $nextCorridorFile, $handoffFile)) {
    if (Test-Path -LiteralPath $file) {
        $content = Get-Content -LiteralPath $file -Raw
        if ($content -match [regex]::Escape($draftCorridor) -or $content -match [regex]::Escape($holdCorridor)) {
            $corridorFound = $true
        }
    }
}
if (-not $corridorFound) {
    Add-Failure 'Neither draft-packet next corridor nor reviewer-assignment hold corridor is present.'
}

$filesToScan = @(
    $terminologySeedFile,
    $reviewerWorkflowFile,
    $glossaryGapLogFile,
    $draftReadinessGateFile,
    $receiptFile,
    $terminologyRegisterFile,
    $pilotGapLogFile,
    $trackerFile,
    $intakeDecisionFile,
    $currentLaneFile,
    $nextCorridorFile,
    $planningFile,
    $handoffFile
)

$translationStartedRegex = '(?i)(Spanish translation has begun|Spanish translation began|translation execution started|Spanish draft created|ES_TRANSLATION_DRAFT\s*[:=]\s*(created|complete|started))'
$publicationReadyRegex = '(?i)(Spanish output is publication-ready|Spanish edition is publication-ready|Spanish publication is ready|ES_PUBLICATION_READY\s*[:=]\s*(created|complete|passed|ready))'
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

$book1ChapterPath = 'D:\Dev\CGPT\Projects\Veristio\Book 1 Human Creativity + AI\manuscript\chapters\chapter_01_work_changed_before_most_people_noticed.md'
if (-not (Test-Path -LiteralPath $book1ChapterPath)) {
    Add-Failure "Book 1 locked Chapter 1 source could not be read for full-manuscript copy check: $book1ChapterPath"
} else {
    $chapterContent = Get-Content -LiteralPath $book1ChapterPath -Raw
    $normalizedChapter = Normalize-CopyCheck -Content $chapterContent
    if ($normalizedChapter.Length -gt 1000) {
        foreach ($file in $filesToScan) {
            if (-not (Test-Path -LiteralPath $file)) {
                continue
            }
            $content = Get-Content -LiteralPath $file -Raw
            $normalizedContent = Normalize-CopyCheck -Content $content
            if ($normalizedContent.Contains($normalizedChapter)) {
                Add-Failure "File appears to contain the full locked Chapter 1 manuscript text: $file"
            }
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
