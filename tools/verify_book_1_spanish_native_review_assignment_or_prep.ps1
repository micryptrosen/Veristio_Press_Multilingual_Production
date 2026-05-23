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
$assignmentFile = Join-Path $packetDir 'BOOK_1_CHAPTER_1_NATIVE_REVIEW_ASSIGNMENT_V1.md'
$instructionsFile = Join-Path $packetDir 'BOOK_1_CHAPTER_1_NATIVE_REVIEW_INSTRUCTIONS_V1.md'
$checklistFile = Join-Path $packetDir 'BOOK_1_CHAPTER_1_NATIVE_REVIEW_CHECKLIST_V1.md'
$statusDecisionFile = Join-Path $packetDir 'BOOK_1_CHAPTER_1_NATIVE_REVIEW_STATUS_DECISION_V1.md'
$receiptFile = Join-Path $repoRoot 'docs/governance/receipts/BOOK_1_SPANISH_NATIVE_REVIEW_ASSIGNMENT_OR_PREP_RECEIPT_V1.md'
$assignmentRegisterFile = Join-Path $packetDir 'BOOK_1_SPANISH_REVIEWER_ASSIGNMENT_REGISTER_V1.md'
$reviewQueueFile = Join-Path $packetDir 'BOOK_1_CHAPTER_1_SPANISH_REVIEW_QUEUE_V1.md'
$trackerFile = Join-Path $packetDir 'BOOK_1_SPANISH_CHAPTER_TRANSLATION_TRACKER_V1.md'
$pilotGapLogFile = Join-Path $packetDir 'BOOK_1_SPANISH_PILOT_GAP_LOG_V1.md'
$currentLaneFile = Join-Path $repoRoot 'controls/CURRENT_WORKING_LANE.md'
$nextCorridorFile = Join-Path $repoRoot 'controls/NEXT_IMPLEMENTATION_CORRIDOR.md'
$planningFile = Join-Path $repoRoot 'docs/planning/PROJECT_PLANNING_RECORD.md'
$handoffFile = Join-Path $repoRoot 'handoff/ARRIVAL_ANCHOR_CURRENT.md'

$requiredFiles = @(
    @{ Path = $assignmentFile; Label = 'Native review assignment file' },
    @{ Path = $instructionsFile; Label = 'Native review instructions file' },
    @{ Path = $checklistFile; Label = 'Native review checklist file' },
    @{ Path = $statusDecisionFile; Label = 'Native review status decision file' },
    @{ Path = $receiptFile; Label = 'Native review assignment/prep receipt' }
)

foreach ($item in $requiredFiles) {
    Assert-Exists -Path $item.Path -Label $item.Label
}

$allowedAssignmentStatuses = @(
    'NATIVE_REVIEWER_ASSIGNED',
    'NATIVE_REVIEW_PACKET_READY_REVIEWER_PENDING',
    'HOLD_FOR_NATIVE_REVIEWER_ASSIGNMENT'
)

$assignmentStatus = $null
if (Test-Path -LiteralPath $assignmentFile) {
    $assignmentContent = Get-Content -LiteralPath $assignmentFile -Raw
    $match = [regex]::Match($assignmentContent, '(?m)^## Native Review Assignment Status\s*\r?\n([A-Z_]+)\s*$')
    if (-not $match.Success) {
        Add-Failure 'Native review assignment file does not declare a status under ## Native Review Assignment Status.'
    } else {
        $assignmentStatus = $match.Groups[1].Value
        if ($allowedAssignmentStatuses -notcontains $assignmentStatus) {
            Add-Failure "Native review assignment status is not allowed: $assignmentStatus"
        }
    }

    if ($assignmentContent -match 'Reviewer name:\s*`UNASSIGNED`' -and $assignmentStatus -eq 'NATIVE_REVIEWER_ASSIGNED') {
        Add-Failure 'Assignment status is assigned even though reviewer name is UNASSIGNED.'
    }

    if ($assignmentContent -match 'Reviewer name:\s*`UNASSIGNED`' -and @('NATIVE_REVIEW_PACKET_READY_REVIEWER_PENDING', 'HOLD_FOR_NATIVE_REVIEWER_ASSIGNMENT') -notcontains $assignmentStatus) {
        Add-Failure 'No reviewer is named, but assignment status is not reviewer-pending or held.'
    }
}

$allowedNativeReviewDecisions = @(
    'READY_FOR_NATIVE_REVIEW',
    'READY_FOR_NATIVE_REVIEW_WITH_CONDITIONS',
    'HOLD_FOR_NATIVE_REVIEWER_ASSIGNMENT',
    'HOLD_FOR_REVIEW_PACKET_REPAIR'
)

if (Test-Path -LiteralPath $statusDecisionFile) {
    $decisionContent = Get-Content -LiteralPath $statusDecisionFile -Raw
    $match = [regex]::Match($decisionContent, '(?m)^## Native Review Status Decision\s*\r?\n([A-Z_]+)\s*$')
    if (-not $match.Success) {
        Add-Failure 'Native review status decision file does not declare a decision under ## Native Review Status Decision.'
    } elseif ($allowedNativeReviewDecisions -notcontains $match.Groups[1].Value) {
        Add-Failure "Native review status decision is not allowed: $($match.Groups[1].Value)"
    }
}

$instructionNeedles = @(
    'natural Spanish',
    'tone/register',
    'terminology decisions',
    'omitted or added meaning',
    'Claim Spanish publication readiness'
)

foreach ($needle in $instructionNeedles) {
    Assert-FileContains -File $instructionsFile -Needle $needle -Label 'Native review instructions required content check'
}

$nextCorridor = 'VERISTIO_PRESS_BOOK_1_SPANISH_NATIVE_REVIEW_EXECUTION_OR_HOLD_V1'
$corridorFound = $false
foreach ($file in @($assignmentFile, $instructionsFile, $checklistFile, $statusDecisionFile, $receiptFile, $reviewQueueFile, $currentLaneFile, $nextCorridorFile, $planningFile, $handoffFile)) {
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
    $assignmentFile,
    $instructionsFile,
    $checklistFile,
    $statusDecisionFile,
    $receiptFile,
    $assignmentRegisterFile,
    $reviewQueueFile,
    $trackerFile,
    $pilotGapLogFile,
    $currentLaneFile,
    $nextCorridorFile,
    $planningFile,
    $handoffFile
)

$nativeReviewCompleteRegex = '(?i)(NATIVE_REVIEW_COMPLETE|native-language review\s*[:=]\s*(complete|completed|passed|approved)|native-language review result\s*[:=]\s*(complete|completed|passed|approved)|native review result\s*[:=]\s*(complete|completed|passed|approved))'
$humanReviewCompleteRegex = '(?i)(HUMAN_REVIEW_COMPLETE|human review\s*[:=]\s*(complete|completed|passed|approved)|human reviewer signoff\s*[:=]\s*(complete|completed|passed|approved))'
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
