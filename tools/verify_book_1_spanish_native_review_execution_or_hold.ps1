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
$executionHoldFile = Join-Path $packetDir 'BOOK_1_CHAPTER_1_NATIVE_REVIEW_EXECUTION_OR_HOLD_V1.md'
$holdRecordFile = Join-Path $packetDir 'BOOK_1_CHAPTER_1_NATIVE_REVIEW_HOLD_RECORD_V1.md'
$findingsFile = Join-Path $packetDir 'BOOK_1_CHAPTER_1_NATIVE_REVIEW_FINDINGS_V1.md'
$reviewDecisionFile = Join-Path $packetDir 'BOOK_1_CHAPTER_1_NATIVE_REVIEW_DECISION_V1.md'
$receiptFile = Join-Path $repoRoot 'docs/governance/receipts/BOOK_1_SPANISH_NATIVE_REVIEW_EXECUTION_OR_HOLD_RECEIPT_V1.md'
$statusDecisionFile = Join-Path $packetDir 'BOOK_1_CHAPTER_1_NATIVE_REVIEW_STATUS_DECISION_V1.md'
$assignmentFile = Join-Path $packetDir 'BOOK_1_CHAPTER_1_NATIVE_REVIEW_ASSIGNMENT_V1.md'
$reviewQueueFile = Join-Path $packetDir 'BOOK_1_CHAPTER_1_SPANISH_REVIEW_QUEUE_V1.md'
$assignmentRegisterFile = Join-Path $packetDir 'BOOK_1_SPANISH_REVIEWER_ASSIGNMENT_REGISTER_V1.md'
$trackerFile = Join-Path $packetDir 'BOOK_1_SPANISH_CHAPTER_TRANSLATION_TRACKER_V1.md'
$pilotGapLogFile = Join-Path $packetDir 'BOOK_1_SPANISH_PILOT_GAP_LOG_V1.md'
$currentLaneFile = Join-Path $repoRoot 'controls/CURRENT_WORKING_LANE.md'
$nextCorridorFile = Join-Path $repoRoot 'controls/NEXT_IMPLEMENTATION_CORRIDOR.md'
$planningFile = Join-Path $repoRoot 'docs/planning/PROJECT_PLANNING_RECORD.md'
$handoffFile = Join-Path $repoRoot 'handoff/ARRIVAL_ANCHOR_CURRENT.md'

Assert-Exists -Path $executionHoldFile -Label 'Native review execution or hold record'
Assert-Exists -Path $receiptFile -Label 'Native review execution or hold receipt'

$allowedDecisions = @(
    'NATIVE_REVIEW_COMPLETED_WITH_FINDINGS',
    'NATIVE_REVIEW_COMPLETED_NO_BLOCKING_FINDINGS',
    'HOLD_FOR_NATIVE_REVIEWER_ASSIGNMENT',
    'HOLD_FOR_NATIVE_REVIEW_EXECUTION'
)

$decision = $null
if (Test-Path -LiteralPath $executionHoldFile) {
    $executionContent = Get-Content -LiteralPath $executionHoldFile -Raw
    $match = [regex]::Match($executionContent, '(?m)^## Execution Or Hold Decision\s*\r?\n([A-Z_]+)\s*$')
    if (-not $match.Success) {
        Add-Failure 'Execution/hold file does not declare a decision under ## Execution Or Hold Decision.'
    } else {
        $decision = $match.Groups[1].Value
        if ($allowedDecisions -notcontains $decision) {
            Add-Failure "Execution/hold decision is not allowed: $decision"
        }
    }
}

$assignmentContent = ''
if (Test-Path -LiteralPath $assignmentFile) {
    $assignmentContent = Get-Content -LiteralPath $assignmentFile -Raw
}

$reviewerNamed = $false
if ($assignmentContent -match '(?im)^-\s*Reviewer name:\s*`?(.+?)`?\s*$') {
    $name = $Matches[1].Trim('`').Trim()
    if ($name -and $name -ne 'UNASSIGNED') {
        $reviewerNamed = $true
    }
}

if ($decision -in @('NATIVE_REVIEW_COMPLETED_WITH_FINDINGS', 'NATIVE_REVIEW_COMPLETED_NO_BLOCKING_FINDINGS')) {
    if (-not $reviewerNamed) {
        Add-Failure 'Native review is marked completed, but no named reviewer is recorded.'
    }
    Assert-Exists -Path $findingsFile -Label 'Native review findings file required for completed review'
    Assert-Exists -Path $reviewDecisionFile -Label 'Native review decision file required for completed review'
}

if (-not $reviewerNamed -and $decision -notin @('HOLD_FOR_NATIVE_REVIEWER_ASSIGNMENT', 'HOLD_FOR_NATIVE_REVIEW_EXECUTION')) {
    Add-Failure 'No named reviewer exists, but decision is not a reviewer-assignment or execution hold.'
}

if ($decision -eq 'HOLD_FOR_NATIVE_REVIEWER_ASSIGNMENT') {
    Assert-Exists -Path $holdRecordFile -Label 'Native review hold record'
    Assert-FileContains -File $holdRecordFile -Needle 'HOLD_FOR_NATIVE_REVIEWER_ASSIGNMENT' -Label 'Hold decision check'
}

$gapRepairCorridor = 'VERISTIO_PRESS_BOOK_1_SPANISH_NATIVE_REVIEW_GAP_REPAIR_V1'
$technicalPrepCorridor = 'VERISTIO_PRESS_BOOK_1_SPANISH_TECHNICAL_REVIEW_PREP_V1'
$corridorFound = $false
foreach ($file in @($executionHoldFile, $holdRecordFile, $receiptFile, $statusDecisionFile, $reviewQueueFile, $assignmentRegisterFile, $trackerFile, $pilotGapLogFile, $currentLaneFile, $nextCorridorFile, $planningFile, $handoffFile)) {
    if (Test-Path -LiteralPath $file) {
        $content = Get-Content -LiteralPath $file -Raw
        if ($content -match [regex]::Escape($gapRepairCorridor) -or $content -match [regex]::Escape($technicalPrepCorridor)) {
            $corridorFound = $true
        }
    }
}
if (-not $corridorFound) {
    Add-Failure 'Neither native-review gap-repair corridor nor technical-review-prep corridor is present.'
}

$filesToScan = @(
    $executionHoldFile,
    $holdRecordFile,
    $receiptFile,
    $statusDecisionFile,
    $assignmentFile,
    $reviewQueueFile,
    $assignmentRegisterFile,
    $trackerFile,
    $pilotGapLogFile,
    $currentLaneFile,
    $nextCorridorFile,
    $planningFile,
    $handoffFile
)

$nativeReviewClaimRegex = '(?i)(native-language review is complete|native-language review completed|native review is complete|native review completed|native-language reviewer signoff granted|native reviewer approval granted)'
$humanReviewClaimRegex = '(?i)(human review is complete|human review completed|human reviewer signoff granted|human reviewer approval granted)'
$finalReviewClaimRegex = '(?i)(final review is complete|final review completed|final sync/proof review is complete|final sync/proof completed|final sync/proof approval granted)'
$publicationReadyRegex = '(?i)(Spanish output is publication-ready|Spanish edition is publication-ready|Spanish publication is ready|publication readiness\s*[:=]\s*(ready|complete|completed|passed|approved)|ES_PUBLICATION_READY\s*[:=]\s*(created|complete|completed|passed|ready|approved))'
$releaseApprovalRegex = '(?i)(final release approval granted|release approval\s*[:=]\s*(approved|complete|completed|passed|ready)|release gate\s*[:=]\s*(approved|complete|completed|passed|ready)|upload-ready files?\s*(prepared|created|approved))'

foreach ($file in $filesToScan) {
    if (-not (Test-Path -LiteralPath $file)) {
        continue
    }

    $content = Get-Content -LiteralPath $file -Raw
    if ($content -match $nativeReviewClaimRegex) {
        Add-Failure "File appears to claim native-language review completion: $file"
    }
    if ($content -match $humanReviewClaimRegex) {
        Add-Failure "File appears to claim human review completion: $file"
    }
    if ($content -match $finalReviewClaimRegex) {
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
