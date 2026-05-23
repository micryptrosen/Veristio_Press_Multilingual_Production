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
$draftRevisionFile = Join-Path $packetDir 'BOOK_1_CHAPTER_1_SPANISH_DRAFT_REVISION_V1.md'
$draftV2File = Join-Path $packetDir 'BOOK_1_CHAPTER_1_SPANISH_DRAFT_V2.md'
$resolutionLogFile = Join-Path $packetDir 'BOOK_1_CHAPTER_1_SPANISH_REVISION_RESOLUTION_LOG_V1.md'
$nativePrepFile = Join-Path $packetDir 'BOOK_1_CHAPTER_1_NATIVE_REVIEW_PREP_PACKET_V1.md'
$postDecisionFile = Join-Path $packetDir 'BOOK_1_CHAPTER_1_SPANISH_POST_REVISION_STATUS_DECISION_V1.md'
$receiptFile = Join-Path $repoRoot 'docs/governance/receipts/BOOK_1_SPANISH_DRAFT_REVISION_OR_NATIVE_REVIEW_PREP_RECEIPT_V1.md'
$reviewQueueFile = Join-Path $packetDir 'BOOK_1_CHAPTER_1_SPANISH_REVIEW_QUEUE_V1.md'
$revisionQueueFile = Join-Path $packetDir 'BOOK_1_CHAPTER_1_SPANISH_REVISION_QUEUE_V1.md'
$qaPrecheckFile = Join-Path $packetDir 'BOOK_1_CHAPTER_1_SPANISH_DRAFT_QA_PRECHECK_V1.md'
$reviewStatusDecisionFile = Join-Path $packetDir 'BOOK_1_CHAPTER_1_SPANISH_REVIEW_STATUS_DECISION_V1.md'
$trackerFile = Join-Path $packetDir 'BOOK_1_SPANISH_CHAPTER_TRANSLATION_TRACKER_V1.md'
$pilotGapLogFile = Join-Path $packetDir 'BOOK_1_SPANISH_PILOT_GAP_LOG_V1.md'
$glossaryGapLogFile = Join-Path $packetDir 'BOOK_1_SPANISH_GLOSSARY_GAP_LOG_V1.md'
$terminologyRegisterFile = Join-Path $repoRoot 'docs/translation/BILINGUAL_TERMINOLOGY_REGISTER_EN_ES_V1.md'
$currentLaneFile = Join-Path $repoRoot 'controls/CURRENT_WORKING_LANE.md'
$nextCorridorFile = Join-Path $repoRoot 'controls/NEXT_IMPLEMENTATION_CORRIDOR.md'
$planningFile = Join-Path $repoRoot 'docs/planning/PROJECT_PLANNING_RECORD.md'
$handoffFile = Join-Path $repoRoot 'handoff/ARRIVAL_ANCHOR_CURRENT.md'

$requiredFiles = @(
    @{ Path = $draftRevisionFile; Label = 'Book 1 Chapter 1 Spanish draft revision file' },
    @{ Path = $draftV2File; Label = 'Book 1 Chapter 1 Spanish draft V2' },
    @{ Path = $resolutionLogFile; Label = 'Book 1 Chapter 1 Spanish revision resolution log' },
    @{ Path = $nativePrepFile; Label = 'Book 1 Chapter 1 native review prep packet' },
    @{ Path = $postDecisionFile; Label = 'Book 1 Chapter 1 Spanish post-revision status decision' },
    @{ Path = $receiptFile; Label = 'Book 1 Spanish draft revision/native review prep receipt' }
)

foreach ($item in $requiredFiles) {
    Assert-Exists -Path $item.Path -Label $item.Label
}

$allowedPostRevisionDecisions = @(
    'READY_FOR_NATIVE_LANGUAGE_REVIEW_PREP',
    'READY_FOR_NATIVE_LANGUAGE_REVIEW_WITH_CONDITIONS',
    'HOLD_FOR_ADDITIONAL_INTERNAL_REVISION',
    'HOLD_FOR_TERMINOLOGY_REPAIR',
    'HOLD_FOR_SOURCE_ALIGNMENT_REPAIR'
)

if (Test-Path -LiteralPath $postDecisionFile) {
    $decisionContent = Get-Content -LiteralPath $postDecisionFile -Raw
    $match = [regex]::Match($decisionContent, '(?m)^## Post-Revision Status Decision\s*\r?\n([A-Z_]+)\s*$')
    if (-not $match.Success) {
        Add-Failure 'Post-revision status decision file does not declare a decision under ## Post-Revision Status Decision.'
    } elseif ($allowedPostRevisionDecisions -notcontains $match.Groups[1].Value) {
        Add-Failure "Post-revision status decision is not allowed: $($match.Groups[1].Value)"
    }
}

Assert-FileContains -File $draftV2File -Needle 'PROVISIONAL DRAFT ONLY' -Label 'Draft V2 provisional boundary check'
Assert-FileContains -File $draftV2File -Needle 'NOT HUMAN REVIEWED' -Label 'Draft V2 human review boundary check'
Assert-FileContains -File $draftV2File -Needle 'NOT NATIVE REVIEWED' -Label 'Draft V2 native review boundary check'
Assert-FileContains -File $draftV2File -Needle 'NOT FINAL' -Label 'Draft V2 final boundary check'
Assert-FileContains -File $draftV2File -Needle 'NOT PUBLICATION READY' -Label 'Draft V2 publication boundary check'

$reviewerCoverage = 'PROVISIONAL_INTERNAL_REVIEW_ALLOWED_FOR_DRAFT_ONLY'
foreach ($file in @($draftRevisionFile, $draftV2File, $resolutionLogFile, $nativePrepFile, $postDecisionFile, $receiptFile, $reviewQueueFile, $trackerFile, $handoffFile)) {
    Assert-FileContains -File $file -Needle $reviewerCoverage -Label 'Provisional/internal-only boundary check'
}

foreach ($file in @($draftRevisionFile, $nativePrepFile, $postDecisionFile, $receiptFile, $handoffFile)) {
    Assert-FileContains -File $file -Needle 'Book 1 remains' -Label 'Authority boundary check'
    Assert-FileContains -File $file -Needle 'canonical English owner' -Label 'Authority boundary canonical owner check'
}

$blockedEvidenceFound = $false
foreach ($file in @($draftV2File, $postDecisionFile, $receiptFile, $trackerFile, $handoffFile)) {
    if (Test-Path -LiteralPath $file) {
        $content = Get-Content -LiteralPath $file -Raw
        if ($content -match '(?i)(release.*blocked|publication.*blocked|publication/release.*blocked)') {
            $blockedEvidenceFound = $true
        }
    }
}
if (-not $blockedEvidenceFound) {
    Add-Failure 'Publication/release blocked boundary is not recorded.'
}

$nextCorridor = 'VERISTIO_PRESS_BOOK_1_SPANISH_NATIVE_REVIEW_ASSIGNMENT_OR_PREP_V1'
$corridorFound = $false
foreach ($file in @($draftRevisionFile, $resolutionLogFile, $nativePrepFile, $postDecisionFile, $receiptFile, $reviewQueueFile, $revisionQueueFile, $currentLaneFile, $nextCorridorFile, $planningFile, $handoffFile)) {
    if (Test-Path -LiteralPath $file) {
        $content = Get-Content -LiteralPath $file -Raw
        if ($content -match [regex]::Escape($nextCorridor)) {
            $corridorFound = $true
        }
    }
}
if (-not $corridorFound) {
    Add-Failure 'Expected next corridor is not present.'
}

$filesToScan = @(
    $draftRevisionFile,
    $draftV2File,
    $resolutionLogFile,
    $nativePrepFile,
    $postDecisionFile,
    $receiptFile,
    $reviewQueueFile,
    $revisionQueueFile,
    $qaPrecheckFile,
    $reviewStatusDecisionFile,
    $trackerFile,
    $pilotGapLogFile,
    $glossaryGapLogFile,
    $terminologyRegisterFile,
    $currentLaneFile,
    $nextCorridorFile,
    $planningFile,
    $handoffFile
)

$nativeReviewCompleteRegex = '(?i)(NATIVE_REVIEW_COMPLETE|native-language review\s*[:=]\s*(complete|completed|passed|approved)|native-language review completion\s*[:=]\s*(complete|completed|passed|approved))'
$humanReviewCompleteRegex = '(?i)(HUMAN_REVIEW_COMPLETE|human review\s*[:=]\s*(complete|completed|passed|approved)|human reviewer signoff\s*[:=]\s*(complete|completed|passed|approved))'
$technicalReviewCompleteRegex = '(?i)(TECHNICAL_REVIEW_COMPLETE|technical review\s*[:=]\s*(complete|completed|passed|approved)|technical review completion\s*[:=]\s*(complete|completed|passed|approved))'
$finalReviewCompleteRegex = '(?i)(FINAL_REVIEW_COMPLETE|final review\s*[:=]\s*(complete|completed|passed|approved)|final sync/proof review\s*[:=]\s*(complete|completed|passed|approved))'
$publicationReadyRegex = '(?i)(Spanish output is publication-ready|Spanish edition is publication-ready|Spanish publication is ready|publication readiness\s*[:=]\s*(ready|complete|completed|passed|approved)|ES_PUBLICATION_READY\s*[:=]\s*(created|complete|completed|passed|ready|approved))'
$releaseApprovalRegex = '(?i)(final release approval granted|release approval\s*[:=]\s*(approved|complete|completed|passed|ready)|release gate\s*[:=]\s*(approved|complete|completed|passed|ready)|upload-ready files?\s*(prepared|created|approved))'

foreach ($file in $filesToScan) {
    if (-not (Test-Path -LiteralPath $file)) {
        continue
    }

    $content = Get-Content -LiteralPath $file -Raw
    if ($content -match $nativeReviewCompleteRegex) {
        Add-Failure "File appears to claim native-language review completion: $file"
    }
    if ($content -match $humanReviewCompleteRegex) {
        Add-Failure "File appears to claim human review completion: $file"
    }
    if ($content -match $technicalReviewCompleteRegex) {
        Add-Failure "File appears to claim technical review completion: $file"
    }
    if ($content -match $finalReviewCompleteRegex) {
        Add-Failure "File appears to claim final review completion: $file"
    }
    if ($content -match $publicationReadyRegex) {
        Add-Failure "File appears to claim Spanish publication readiness: $file"
    }
    if ($content -match $releaseApprovalRegex) {
        Add-Failure "File appears to claim release approval or upload readiness: $file"
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
