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
$draftReviewFile = Join-Path $packetDir 'BOOK_1_CHAPTER_1_SPANISH_DRAFT_REVIEW_V1.md'
$terminologyPassFile = Join-Path $packetDir 'BOOK_1_CHAPTER_1_SPANISH_TERMINOLOGY_PASS_V1.md'
$revisionQueueFile = Join-Path $packetDir 'BOOK_1_CHAPTER_1_SPANISH_REVISION_QUEUE_V1.md'
$reviewStatusDecisionFile = Join-Path $packetDir 'BOOK_1_CHAPTER_1_SPANISH_REVIEW_STATUS_DECISION_V1.md'
$receiptFile = Join-Path $repoRoot 'docs/governance/receipts/BOOK_1_SPANISH_DRAFT_REVIEW_AND_TERMINOLOGY_PASS_RECEIPT_V1.md'
$reviewQueueFile = Join-Path $packetDir 'BOOK_1_CHAPTER_1_SPANISH_REVIEW_QUEUE_V1.md'
$qaPrecheckFile = Join-Path $packetDir 'BOOK_1_CHAPTER_1_SPANISH_DRAFT_QA_PRECHECK_V1.md'
$terminologySeedFile = Join-Path $packetDir 'BOOK_1_SPANISH_TERMINOLOGY_SEED_V1.md'
$glossaryGapLogFile = Join-Path $packetDir 'BOOK_1_SPANISH_GLOSSARY_GAP_LOG_V1.md'
$trackerFile = Join-Path $packetDir 'BOOK_1_SPANISH_CHAPTER_TRANSLATION_TRACKER_V1.md'
$pilotGapLogFile = Join-Path $packetDir 'BOOK_1_SPANISH_PILOT_GAP_LOG_V1.md'
$terminologyRegisterFile = Join-Path $repoRoot 'docs/translation/BILINGUAL_TERMINOLOGY_REGISTER_EN_ES_V1.md'
$currentLaneFile = Join-Path $repoRoot 'controls/CURRENT_WORKING_LANE.md'
$nextCorridorFile = Join-Path $repoRoot 'controls/NEXT_IMPLEMENTATION_CORRIDOR.md'
$planningFile = Join-Path $repoRoot 'docs/planning/PROJECT_PLANNING_RECORD.md'
$handoffFile = Join-Path $repoRoot 'handoff/ARRIVAL_ANCHOR_CURRENT.md'

$requiredFiles = @(
    @{ Path = $draftReviewFile; Label = 'Book 1 Chapter 1 Spanish draft review' },
    @{ Path = $terminologyPassFile; Label = 'Book 1 Chapter 1 Spanish terminology pass' },
    @{ Path = $revisionQueueFile; Label = 'Book 1 Chapter 1 Spanish revision queue' },
    @{ Path = $reviewStatusDecisionFile; Label = 'Book 1 Chapter 1 Spanish review status decision' },
    @{ Path = $receiptFile; Label = 'Book 1 Spanish draft review and terminology pass receipt' }
)

foreach ($item in $requiredFiles) {
    Assert-Exists -Path $item.Path -Label $item.Label
}

$allowedReviewStatusDecisions = @(
    'PROVISIONAL_REVIEW_PASS_FOR_NEXT_REVIEW_STAGE',
    'PROVISIONAL_REVIEW_PASS_WITH_REVISIONS_REQUIRED',
    'HOLD_FOR_TERMINOLOGY_REPAIR',
    'HOLD_FOR_NATIVE_LANGUAGE_REVIEW',
    'HOLD_FOR_TECHNICAL_REVIEW',
    'HOLD_FOR_SOURCE_ALIGNMENT_REPAIR'
)

if (Test-Path -LiteralPath $reviewStatusDecisionFile) {
    $decisionContent = Get-Content -LiteralPath $reviewStatusDecisionFile -Raw
    $match = [regex]::Match($decisionContent, '(?m)^## Review Status Decision\s*\r?\n([A-Z_]+)\s*$')
    if (-not $match.Success) {
        Add-Failure 'Review status decision file does not declare a decision under ## Review Status Decision.'
    } elseif ($allowedReviewStatusDecisions -notcontains $match.Groups[1].Value) {
        Add-Failure "Review status decision is not allowed: $($match.Groups[1].Value)"
    }
}

$reviewerCoverage = 'PROVISIONAL_INTERNAL_REVIEW_ALLOWED_FOR_DRAFT_ONLY'
foreach ($file in @($draftReviewFile, $terminologyPassFile, $revisionQueueFile, $reviewStatusDecisionFile, $receiptFile, $reviewQueueFile, $trackerFile, $handoffFile)) {
    Assert-FileContains -File $file -Needle $reviewerCoverage -Label 'Provisional/internal-only boundary check'
}

$terminologyReferenceFound = $false
if (Test-Path -LiteralPath $terminologyPassFile) {
    $terminologyPassContent = Get-Content -LiteralPath $terminologyPassFile -Raw
    if (
        $terminologyPassContent -match [regex]::Escape('BOOK_1_SPANISH_TERMINOLOGY_SEED_V1.md') -or
        $terminologyPassContent -match [regex]::Escape('BILINGUAL_TERMINOLOGY_REGISTER_EN_ES_V1.md')
    ) {
        $terminologyReferenceFound = $true
    }
}
if (-not $terminologyReferenceFound) {
    Add-Failure 'Terminology pass does not reference the terminology seed or register.'
}

$reviewRoles = @(
    'terminology review',
    'native-language review',
    'technical review',
    'final sync/proof review'
)

foreach ($role in $reviewRoles) {
    Assert-FileContains -File $reviewQueueFile -Needle $role -Label "Review queue role check: $role"
}

foreach ($file in @($draftReviewFile, $terminologyPassFile, $reviewStatusDecisionFile, $receiptFile, $handoffFile)) {
    Assert-FileContains -File $file -Needle 'Book 1 remains' -Label 'Authority boundary check'
    Assert-FileContains -File $file -Needle 'canonical' -Label 'Authority boundary canonical check'
}

$nextCorridor = 'VERISTIO_PRESS_BOOK_1_SPANISH_DRAFT_REVISION_OR_NATIVE_REVIEW_PREP_V1'
$corridorFound = $false
foreach ($file in @($draftReviewFile, $terminologyPassFile, $revisionQueueFile, $reviewStatusDecisionFile, $receiptFile, $reviewQueueFile, $currentLaneFile, $nextCorridorFile, $planningFile, $handoffFile)) {
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
    $draftReviewFile,
    $terminologyPassFile,
    $revisionQueueFile,
    $reviewStatusDecisionFile,
    $receiptFile,
    $reviewQueueFile,
    $qaPrecheckFile,
    $terminologySeedFile,
    $glossaryGapLogFile,
    $trackerFile,
    $pilotGapLogFile,
    $terminologyRegisterFile,
    $currentLaneFile,
    $nextCorridorFile,
    $planningFile,
    $handoffFile
)

$nativeReviewCompleteRegex = '(?i)(NATIVE_REVIEW_COMPLETE|native-language review\s*[:=]\s*(complete|completed|passed|approved)|native-language review completion\s*[:=]\s*(complete|completed|passed|approved))'
$humanReviewCompleteRegex = '(?i)(HUMAN_REVIEW_COMPLETE|human review\s*[:=]\s*(complete|completed|passed|approved)|named human reviewer signoff\s*[:=]\s*(complete|completed|passed|approved))'
$finalReviewCompleteRegex = '(?i)(FINAL_REVIEW_COMPLETE|final review\s*[:=]\s*(complete|completed|passed|approved)|final sync/proof review\s*[:=]\s*(complete|completed|passed|approved))'
$publicationReadyRegex = '(?i)(Spanish output is publication-ready|Spanish edition is publication-ready|Spanish publication is ready|publication readiness\s*[:=]\s*(ready|complete|completed|passed|approved)|ES_PUBLICATION_READY\s*[:=]\s*(created|complete|completed|passed|ready|approved))'
$releaseApprovalRegex = '(?i)(final release approval granted|release approval\s*[:=]\s*(approved|complete|completed|passed|ready)|RELEASE_READY\s*[:=]\s*(true|complete|completed|passed|approved)|upload-ready)'

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
    if ($content -match $finalReviewCompleteRegex) {
        Add-Failure "File appears to claim final review completion: $file"
    }
    if ($content -match $publicationReadyRegex) {
        Add-Failure "File appears to claim Spanish publication readiness: $file"
    }
    if ($content -match $releaseApprovalRegex) {
        Add-Failure "File appears to claim release approval: $file"
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
