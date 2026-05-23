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

$reviewerProgramDir = Join-Path $repoRoot 'docs/reviewer_program'
$packetDir = Join-Path $repoRoot 'docs/packets/book_1_human_creativity_ai_synthesis'
$receiptsDir = Join-Path $repoRoot 'docs/governance/receipts'

$gapRepairPlanFile = Join-Path $reviewerProgramDir 'SPANISH_NATIVE_REVIEWER_GAP_REPAIR_PLAN_V1.md'
$qualificationFile = Join-Path $reviewerProgramDir 'SPANISH_NATIVE_REVIEWER_QUALIFICATION_CRITERIA_V1.md'
$onboardingFile = Join-Path $reviewerProgramDir 'SPANISH_NATIVE_REVIEWER_ONBOARDING_PACKET_V1.md'
$sampleProtocolFile = Join-Path $reviewerProgramDir 'SPANISH_NATIVE_REVIEWER_EVALUATION_SAMPLE_PROTOCOL_V1.md'
$assignmentTemplateFile = Join-Path $reviewerProgramDir 'SPANISH_NATIVE_REVIEWER_ASSIGNMENT_RECORD_TEMPLATE_V1.md'
$receiptFile = Join-Path $receiptsDir 'BOOK_1_SPANISH_NATIVE_REVIEW_GAP_REPAIR_RECEIPT_V1.md'

$assignmentRegisterFile = Join-Path $packetDir 'BOOK_1_SPANISH_REVIEWER_ASSIGNMENT_REGISTER_V1.md'
$pilotGapLogFile = Join-Path $packetDir 'BOOK_1_SPANISH_PILOT_GAP_LOG_V1.md'
$trackerFile = Join-Path $packetDir 'BOOK_1_SPANISH_CHAPTER_TRANSLATION_TRACKER_V1.md'
$assignmentFile = Join-Path $packetDir 'BOOK_1_CHAPTER_1_NATIVE_REVIEW_ASSIGNMENT_V1.md'
$currentLaneFile = Join-Path $repoRoot 'controls/CURRENT_WORKING_LANE.md'
$nextCorridorFile = Join-Path $repoRoot 'controls/NEXT_IMPLEMENTATION_CORRIDOR.md'
$planningFile = Join-Path $repoRoot 'docs/planning/PROJECT_PLANNING_RECORD.md'
$handoffFile = Join-Path $repoRoot 'handoff/ARRIVAL_ANCHOR_CURRENT.md'

$requiredFiles = @(
    @{ Path = $gapRepairPlanFile; Label = 'Native reviewer gap repair plan' },
    @{ Path = $qualificationFile; Label = 'Native reviewer qualification criteria' },
    @{ Path = $onboardingFile; Label = 'Native reviewer onboarding packet' },
    @{ Path = $sampleProtocolFile; Label = 'Native reviewer evaluation sample protocol' },
    @{ Path = $assignmentTemplateFile; Label = 'Native reviewer assignment record template' },
    @{ Path = $receiptFile; Label = 'Native reviewer gap repair receipt' }
)

foreach ($item in $requiredFiles) {
    Assert-Exists -Path $item.Path -Label $item.Label
}

$packageFiles = @($gapRepairPlanFile, $qualificationFile, $onboardingFile, $sampleProtocolFile, $assignmentTemplateFile, $receiptFile)
$packageContent = ''
foreach ($file in $packageFiles) {
    if (Test-Path -LiteralPath $file) {
        $packageContent += "`n--- $file ---`n"
        $packageContent += Get-Content -LiteralPath $file -Raw
    }
}

if ($packageContent -notmatch 'HOLD_FOR_OPERATOR_REVIEWER_SELECTION') {
    Add-Failure 'Gap repair package does not record HOLD_FOR_OPERATOR_REVIEWER_SELECTION.'
}

if ($packageContent -notmatch 'publication remains blocked until documented native review occurs') {
    Add-Failure 'Gap repair package does not state publication remains blocked until documented native review occurs.'
}

$requiredPackagePhrases = @(
    'native Spanish fluency',
    'neutral Spanish',
    'technical review',
    'Confidentiality',
    'AI-use boundary',
    'sample protocol',
    'acceptance standard',
    'rejection',
    'assignment record',
    'Signoff'
)
foreach ($phrase in $requiredPackagePhrases) {
    if ($packageContent -notmatch [regex]::Escape($phrase)) {
        Add-Failure "Gap repair package missing required concept: $phrase"
    }
}

# The package may contain templates and UNASSIGNED placeholders, but it must not record a real reviewer.
$inventedReviewerPatterns = @(
    '(?im)^\s*[-*]?\s*Reviewer name:\s*`?(?!UNASSIGNED|PENDING|TBD)([^`\r\n]+)`?\s*$',
    '(?im)^\s*\|\s*reviewer_name\s*\|\s*(?!\s*(UNASSIGNED_UNTIL_OPERATOR_SELECTION|PENDING|value_to_record))([^|]+)\|',
    '(?im)^\s*\|\s*candidate_reviewer_name\s*\|\s*(?!\s*(UNASSIGNED|PENDING|value_to_record))([^|]+)\|',
    '(?im)^\s*reviewer_name\s*:\s*(?!`?UNASSIGNED`?|`?PENDING`?|`?TBD`?|<)(.+)$'
)
foreach ($pattern in $inventedReviewerPatterns) {
    $match = [regex]::Match($packageContent, $pattern)
    if ($match.Success) {
        Add-Failure "Gap repair package appears to name a reviewer or non-placeholder reviewer value: $($match.Value.Trim())"
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

if (-not $reviewerNamed) {
    Assert-FileContains -File $assignmentRegisterFile -Needle 'Named reviewer posture: `NO_NAMED_REVIEWERS_ASSIGNED`' -Label 'Assignment register pending reviewer check'
    Assert-FileContains -File $assignmentRegisterFile -Needle 'Native review assignment status: `NATIVE_REVIEW_PACKET_READY_REVIEWER_PENDING`' -Label 'Assignment register pending status check'
    Assert-FileContains -File $assignmentRegisterFile -Needle '| native-language reviewer | NOT_ASSIGNED | HOLD_FOR_OPERATOR_REVIEWER_SELECTION |' -Label 'Native reviewer row pending status check'
}

$nextCorridor = 'VERISTIO_PRESS_BOOK_1_SPANISH_REVIEWER_SELECTION_OR_NATIVE_REVIEW_EXECUTION_V1'
$corridorFound = $false
foreach ($file in @($gapRepairPlanFile, $qualificationFile, $onboardingFile, $sampleProtocolFile, $assignmentTemplateFile, $receiptFile, $assignmentRegisterFile, $pilotGapLogFile, $trackerFile, $currentLaneFile, $nextCorridorFile, $planningFile, $handoffFile)) {
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
    $gapRepairPlanFile,
    $qualificationFile,
    $onboardingFile,
    $sampleProtocolFile,
    $assignmentTemplateFile,
    $receiptFile,
    $assignmentRegisterFile,
    $pilotGapLogFile,
    $trackerFile,
    $currentLaneFile,
    $nextCorridorFile,
    $planningFile,
    $handoffFile
)

$nativeReviewCompleteRegex = '(?i)(NATIVE_REVIEW_COMPLETE|native-language review\s*[:=]\s*(complete|completed|passed|approved)|native-language review result\s*[:=]\s*(complete|completed|passed|approved)|native review result\s*[:=]\s*(complete|completed|passed|approved)|native-language review completed|native review completed)'
$humanReviewCompleteRegex = '(?i)(HUMAN_REVIEW_COMPLETE|human review\s*[:=]\s*(complete|completed|passed|approved)|human reviewer signoff\s*[:=]\s*(complete|completed|passed|approved))'
$technicalReviewCompleteRegex = '(?i)(TECHNICAL_REVIEW_COMPLETE|technical review\s*[:=]\s*(complete|completed|passed|approved)|technical reviewer signoff\s*[:=]\s*(complete|completed|passed|approved))'
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
